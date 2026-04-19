import SwiftUI
import SwiftData

struct StudentDetailView: View {
    @Bindable var student: Student
    @Environment(\.modelContext) private var context
    @State private var showingEdit = false
    @State private var showingAddLesson = false

    private var sortedLessons: [Lesson] {
        student.lessons.sorted { $0.date > $1.date }
    }

    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    Stat(title: "Hours", value: Format.hours(student.totalHours))
                    Divider()
                    Stat(title: "Lessons", value: "\(student.completedLessonsCount)")
                    Divider()
                    Stat(title: "Paid", value: Format.money(student.totalEarned))
                }
                if student.outstandingBalance > 0 {
                    HStack {
                        Label("Outstanding", systemImage: "exclamationmark.circle")
                        Spacer()
                        Text(Format.money(student.outstandingBalance)).bold()
                    }
                    .foregroundStyle(.orange)
                }
            }

            Section("Contact") {
                if !student.phone.isEmpty {
                    Link(destination: URL(string: "tel:\(student.phone.filter { !$0.isWhitespace })")!) {
                        Label(student.phone, systemImage: "phone")
                    }
                }
                if !student.email.isEmpty {
                    Link(destination: URL(string: "mailto:\(student.email)")!) {
                        Label(student.email, systemImage: "envelope")
                    }
                }
                if !student.pickupAddress.isEmpty || !student.postcode.isEmpty {
                    let q = "\(student.pickupAddress) \(student.postcode)".trimmingCharacters(in: .whitespaces)
                    Link(destination: mapsURL(for: q)) {
                        Label("\(student.pickupAddress)\n\(student.postcode)", systemImage: "mappin.and.ellipse")
                            .multilineTextAlignment(.leading)
                    }
                }
            }

            Section("Details") {
                LabeledContent("Transmission", value: student.transmission.rawValue)
                LabeledContent("Rate", value: "\(Format.money(student.hourlyRate)) /hr")
                if !student.licenceNumber.isEmpty {
                    LabeledContent("Licence", value: student.licenceNumber)
                }
                LabeledContent("Theory", value: student.theoryTestPassed ? "Passed" : "Not passed")
                if let d = student.theoryTestDate {
                    LabeledContent("Theory date", value: Format.dayOnly.string(from: d))
                }
                if let d = student.practicalTestDate {
                    LabeledContent("Practical date", value: Format.dayOnly.string(from: d))
                }
            }

            if !student.notes.isEmpty {
                Section("Notes") {
                    Text(student.notes)
                }
            }

            Section("Lessons") {
                if sortedLessons.isEmpty {
                    Text("No lessons booked").foregroundStyle(.secondary)
                } else {
                    ForEach(sortedLessons) { lesson in
                        NavigationLink {
                            LessonFormView(mode: .edit(lesson))
                        } label: {
                            LessonRow(lesson: lesson)
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            context.delete(sortedLessons[index])
                        }
                    }
                }
            }
        }
        .navigationTitle(student.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { showingAddLesson = true } label: {
                        Label("Book lesson", systemImage: "calendar.badge.plus")
                    }
                    Button { showingEdit = true } label: {
                        Label("Edit student", systemImage: "pencil")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            StudentFormView(mode: .edit(student))
        }
        .sheet(isPresented: $showingAddLesson) {
            LessonFormView(mode: .add(prefilledStudent: student))
        }
    }

    private func mapsURL(for query: String) -> URL {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "http://maps.apple.com/?q=\(encoded)")!
    }
}

private struct Stat: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.headline)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
