import SwiftUI
import SwiftData

struct StudentFormView: View {
    enum Mode {
        case add
        case edit(Student)
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let mode: Mode

    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var pickupAddress = ""
    @State private var postcode = ""
    @State private var licenceNumber = ""
    @State private var transmission: TransmissionType = .manual
    @State private var hourlyRate: Double = 35
    @State private var theoryTestPassed = false
    @State private var hasTheoryDate = false
    @State private var theoryTestDate = Date()
    @State private var hasPracticalDate = false
    @State private var practicalTestDate = Date()
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Contact") {
                    TextField("Full name", text: $name)
                    TextField("Phone", text: $phone).keyboardType(.phonePad)
                    TextField("Email", text: $email).keyboardType(.emailAddress).autocapitalization(.none)
                }

                Section("Pickup") {
                    TextField("Address", text: $pickupAddress)
                    TextField("Postcode", text: $postcode).autocapitalization(.allCharacters)
                }

                Section("Licence") {
                    TextField("Provisional licence number", text: $licenceNumber).autocapitalization(.allCharacters)
                    Picker("Transmission", selection: $transmission) {
                        ForEach(TransmissionType.allCases) { Text($0.rawValue).tag($0) }
                    }
                }

                Section("Rate") {
                    HStack {
                        Text("£")
                        TextField("Hourly rate", value: $hourlyRate, format: .number)
                            .keyboardType(.decimalPad)
                        Text("/hr")
                    }
                }

                Section("Theory test") {
                    Toggle("Passed", isOn: $theoryTestPassed)
                    Toggle("Booked date", isOn: $hasTheoryDate)
                    if hasTheoryDate {
                        DatePicker("Theory date", selection: $theoryTestDate, displayedComponents: [.date])
                    }
                }

                Section("Practical test") {
                    Toggle("Booked date", isOn: $hasPracticalDate)
                    if hasPracticalDate {
                        DatePicker("Practical date", selection: $practicalTestDate, displayedComponents: [.date])
                    }
                }

                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical).lineLimit(3...8)
                }
            }
            .navigationTitle(isEdit ? "Edit student" : "New student")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save).disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear(perform: load)
        }
    }

    private var isEdit: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func load() {
        guard case let .edit(student) = mode else { return }
        name = student.name
        phone = student.phone
        email = student.email
        pickupAddress = student.pickupAddress
        postcode = student.postcode
        licenceNumber = student.licenceNumber
        transmission = student.transmission
        hourlyRate = student.hourlyRate
        theoryTestPassed = student.theoryTestPassed
        if let d = student.theoryTestDate {
            hasTheoryDate = true
            theoryTestDate = d
        }
        if let d = student.practicalTestDate {
            hasPracticalDate = true
            practicalTestDate = d
        }
        notes = student.notes
    }

    private func save() {
        switch mode {
        case .add:
            let student = Student(
                name: name,
                phone: phone,
                email: email,
                pickupAddress: pickupAddress,
                postcode: postcode,
                licenceNumber: licenceNumber,
                transmission: transmission,
                hourlyRate: hourlyRate,
                theoryTestPassed: theoryTestPassed,
                theoryTestDate: hasTheoryDate ? theoryTestDate : nil,
                practicalTestDate: hasPracticalDate ? practicalTestDate : nil,
                notes: notes
            )
            context.insert(student)
        case .edit(let student):
            student.name = name
            student.phone = phone
            student.email = email
            student.pickupAddress = pickupAddress
            student.postcode = postcode
            student.licenceNumber = licenceNumber
            student.transmission = transmission
            student.hourlyRate = hourlyRate
            student.theoryTestPassed = theoryTestPassed
            student.theoryTestDate = hasTheoryDate ? theoryTestDate : nil
            student.practicalTestDate = hasPracticalDate ? practicalTestDate : nil
            student.notes = notes
        }
        dismiss()
    }
}
