import SwiftUI
import SwiftData
import MapKit

struct LessonFormView: View {
    enum Mode {
        case add(prefilledStudent: Student?)
        case edit(Lesson)
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \Student.name) private var allStudents: [Student]

    let mode: Mode

    @State private var selectedStudent: Student?
    @State private var date = Date()
    @State private var durationHours: Double = 1.0
    @State private var pickupLocation = ""
    @State private var dropoffLocation = ""
    @State private var topicsCovered = ""
    @State private var notes = ""
    @State private var amount: Double = 35
    @State private var paid = false

    private let commonTopics = [
        "Cockpit drill", "Moving off & stopping", "Junctions", "Roundabouts",
        "Manoeuvres", "Parallel park", "Bay parking", "Emergency stop",
        "Dual carriageway", "Independent driving", "Mock test"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Student") {
                    Picker("Student", selection: $selectedStudent) {
                        Text("Select…").tag(Optional<Student>.none)
                        ForEach(allStudents) { student in
                            Text(student.name).tag(Optional(student))
                        }
                    }
                }

                Section("When") {
                    DatePicker("Date & time", selection: $date)
                    HStack {
                        Text("Duration")
                        Spacer()
                        Stepper(value: $durationHours, in: 0.5...8, step: 0.5) {
                            Text(Format.hours(durationHours))
                        }
                    }
                }

                Section("Locations") {
                    HStack {
                        TextField("Pickup", text: $pickupLocation)
                        if !pickupLocation.isEmpty {
                            Button {
                                openInMaps(pickupLocation)
                            } label: {
                                Image(systemName: "map")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    HStack {
                        TextField("Drop-off (optional)", text: $dropoffLocation)
                        if !dropoffLocation.isEmpty {
                            Button {
                                openInMaps(dropoffLocation)
                            } label: {
                                Image(systemName: "map")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }

                Section("Topics covered") {
                    TextField("Comma-separated topics", text: $topicsCovered, axis: .vertical)
                        .lineLimit(2...4)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(commonTopics, id: \.self) { topic in
                                Button {
                                    appendTopic(topic)
                                } label: {
                                    Text(topic)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color(.tertiarySystemFill))
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                Section("Notes") {
                    TextField("Lesson notes", text: $notes, axis: .vertical).lineLimit(3...8)
                }

                Section("Payment") {
                    HStack {
                        Text("£")
                        TextField("Amount", value: $amount, format: .number)
                            .keyboardType(.decimalPad)
                    }
                    Toggle("Paid", isOn: $paid)
                }

                if case .edit = mode {} else {
                    EmptyView()
                }
            }
            .navigationTitle(isEdit ? "Edit lesson" : "New lesson")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save).disabled(selectedStudent == nil)
                }
            }
            .onAppear(perform: load)
            .onChange(of: selectedStudent) { _, new in
                guard case .add = mode, let student = new else { return }
                if amount == 35 { amount = student.hourlyRate * durationHours }
                if pickupLocation.isEmpty {
                    let addr = "\(student.pickupAddress) \(student.postcode)"
                        .trimmingCharacters(in: .whitespaces)
                    pickupLocation = addr
                }
            }
            .onChange(of: durationHours) { _, new in
                if case .add = mode, let student = selectedStudent {
                    amount = student.hourlyRate * new
                }
            }
        }
    }

    private var isEdit: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func appendTopic(_ topic: String) {
        if topicsCovered.isEmpty {
            topicsCovered = topic
        } else if !topicsCovered.contains(topic) {
            topicsCovered += ", \(topic)"
        }
    }

    private func openInMaps(_ query: String) {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "http://maps.apple.com/?q=\(encoded)") {
            UIApplication.shared.open(url)
        }
    }

    private func load() {
        switch mode {
        case .add(let prefilled):
            selectedStudent = prefilled
            if let s = prefilled {
                pickupLocation = "\(s.pickupAddress) \(s.postcode)"
                    .trimmingCharacters(in: .whitespaces)
                amount = s.hourlyRate * durationHours
            }
            if let rounded = Calendar.current.nextDate(
                after: Date(),
                matching: DateComponents(minute: 0),
                matchingPolicy: .nextTime
            ) {
                date = rounded
            }
        case .edit(let lesson):
            selectedStudent = lesson.student
            date = lesson.date
            durationHours = lesson.durationHours
            pickupLocation = lesson.pickupLocation
            dropoffLocation = lesson.dropoffLocation
            topicsCovered = lesson.topicsCovered
            notes = lesson.notes
            amount = lesson.amount
            paid = lesson.paid
        }
    }

    private func save() {
        switch mode {
        case .add:
            let lesson = Lesson(
                date: date,
                durationHours: durationHours,
                pickupLocation: pickupLocation,
                dropoffLocation: dropoffLocation,
                topicsCovered: topicsCovered,
                notes: notes,
                amount: amount,
                paid: paid,
                student: selectedStudent
            )
            context.insert(lesson)
        case .edit(let lesson):
            lesson.student = selectedStudent
            lesson.date = date
            lesson.durationHours = durationHours
            lesson.pickupLocation = pickupLocation
            lesson.dropoffLocation = dropoffLocation
            lesson.topicsCovered = topicsCovered
            lesson.notes = notes
            lesson.amount = amount
            lesson.paid = paid
        }
        dismiss()
    }
}
