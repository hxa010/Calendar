import SwiftUI
import SwiftData

struct LessonsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Lesson.date, order: .reverse) private var lessons: [Lesson]
    @State private var showingAdd = false
    @State private var filter: Filter = .all

    enum Filter: String, CaseIterable, Identifiable {
        case all = "All"
        case upcoming = "Upcoming"
        case past = "Past"
        case unpaid = "Unpaid"
        var id: String { rawValue }
    }

    private var filtered: [Lesson] {
        let now = Date()
        switch filter {
        case .all: return lessons
        case .upcoming: return lessons.filter { $0.date > now }
        case .past: return lessons.filter { $0.date <= now }
        case .unpaid: return lessons.filter { !$0.paid }
        }
    }

    private var grouped: [(key: String, value: [Lesson])] {
        let groups = Dictionary(grouping: filtered) { lesson in
            Format.dayOnly.string(from: lesson.date)
        }
        return groups.sorted {
            guard let a = $0.value.first?.date, let b = $1.value.first?.date else { return false }
            return a > b
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Picker("Filter", selection: $filter) {
                    ForEach(Filter.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .padding(.bottom, 4)

                ForEach(grouped, id: \.key) { section in
                    Section(section.key) {
                        ForEach(section.value) { lesson in
                            NavigationLink {
                                LessonFormView(mode: .edit(lesson))
                            } label: {
                                LessonRow(lesson: lesson)
                            }
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                context.delete(section.value[index])
                            }
                        }
                    }
                }
            }
            .overlay {
                if lessons.isEmpty {
                    ContentUnavailableView(
                        "No lessons yet",
                        systemImage: "calendar.badge.plus",
                        description: Text("Tap + to book a lesson.")
                    )
                }
            }
            .navigationTitle("Lessons")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingAdd) {
                LessonFormView(mode: .add(prefilledStudent: nil))
            }
        }
    }
}
