import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var students: [Student]
    @Query(sort: \Lesson.date) private var lessons: [Lesson]

    private var now: Date { Date() }

    private var todayLessons: [Lesson] {
        lessons.filter { Calendar.current.isDateInToday($0.date) }
    }

    private var upcomingLessons: [Lesson] {
        lessons.filter { $0.date > now }.prefix(5).map { $0 }
    }

    private var hoursThisWeek: Double {
        let cal = Calendar.current
        guard let weekStart = cal.dateInterval(of: .weekOfYear, for: now)?.start,
              let weekEnd = cal.dateInterval(of: .weekOfYear, for: now)?.end else { return 0 }
        return lessons
            .filter { $0.date >= weekStart && $0.date < weekEnd }
            .reduce(0) { $0 + $1.durationHours }
    }

    private var earningsThisMonth: Double {
        let cal = Calendar.current
        guard let monthStart = cal.dateInterval(of: .month, for: now)?.start,
              let monthEnd = cal.dateInterval(of: .month, for: now)?.end else { return 0 }
        return lessons
            .filter { $0.paid && $0.date >= monthStart && $0.date < monthEnd }
            .reduce(0) { $0 + $1.amount }
    }

    private var outstanding: Double {
        lessons.filter { !$0.paid && $0.date <= now }.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(title: "Students", value: "\(students.count)", icon: "person.2.fill", tint: .blue)
                        StatCard(title: "Hours this week", value: Format.hours(hoursThisWeek), icon: "clock.fill", tint: .green)
                        StatCard(title: "Earnings (month)", value: Format.money(earningsThisMonth), icon: "sterlingsign.circle.fill", tint: .purple)
                        StatCard(title: "Outstanding", value: Format.money(outstanding), icon: "exclamationmark.circle.fill", tint: .orange)
                    }

                    SectionCard(title: "Today") {
                        if todayLessons.isEmpty {
                            Text("No lessons today")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        } else {
                            ForEach(todayLessons) { lesson in
                                LessonRow(lesson: lesson)
                            }
                        }
                    }

                    SectionCard(title: "Upcoming") {
                        if upcomingLessons.isEmpty {
                            Text("No upcoming lessons")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        } else {
                            ForEach(upcomingLessons) { lesson in
                                LessonRow(lesson: lesson)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon).foregroundStyle(tint)
                Spacer()
            }
            Text(value).font(.title2).bold()
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct SectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            VStack(spacing: 8) { content() }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct LessonRow: View {
    let lesson: Lesson

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(lesson.student?.name ?? "Unknown")
                    .font(.subheadline).bold()
                Text(Format.dayTime.string(from: lesson.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !lesson.pickupLocation.isEmpty {
                    Text(lesson.pickupLocation)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(Format.hours(lesson.durationHours)).font(.caption)
                Text(Format.money(lesson.amount))
                    .font(.caption)
                    .foregroundStyle(lesson.paid ? .green : .orange)
            }
        }
        .padding(.vertical, 4)
    }
}
