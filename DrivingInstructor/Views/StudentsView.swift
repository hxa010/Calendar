import SwiftUI
import SwiftData

struct StudentsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Student.name) private var students: [Student]
    @State private var showingAdd = false
    @State private var searchText = ""

    private var filtered: [Student] {
        guard !searchText.isEmpty else { return students }
        return students.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.postcode.localizedCaseInsensitiveContains(searchText) ||
            $0.phone.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered) { student in
                    NavigationLink(value: student) {
                        StudentRow(student: student)
                    }
                }
                .onDelete(perform: delete)
            }
            .overlay {
                if students.isEmpty {
                    ContentUnavailableView(
                        "No students yet",
                        systemImage: "person.crop.circle.badge.plus",
                        description: Text("Tap + to add your first student.")
                    )
                }
            }
            .searchable(text: $searchText, prompt: "Search name, postcode or phone")
            .navigationTitle("Students")
            .navigationDestination(for: Student.self) { StudentDetailView(student: $0) }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                StudentFormView(mode: .add)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            context.delete(filtered[index])
        }
    }
}

struct StudentRow: View {
    let student: Student

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color.blue.opacity(0.15))
                Text(initials(for: student.name))
                    .font(.subheadline).bold()
                    .foregroundStyle(.blue)
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(student.name).font(.body).bold()
                HStack(spacing: 8) {
                    Label(Format.hours(student.totalHours), systemImage: "clock")
                    Label(student.transmission.rawValue, systemImage: "car")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer()
            if student.outstandingBalance > 0 {
                Text(Format.money(student.outstandingBalance))
                    .font(.caption).bold()
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 4)
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let first = parts.first?.first.map(String.init) ?? "?"
        let last = parts.dropFirst().first?.first.map(String.init) ?? ""
        return (first + last).uppercased()
    }
}
