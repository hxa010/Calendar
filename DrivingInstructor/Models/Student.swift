import Foundation
import SwiftData

enum TransmissionType: String, Codable, CaseIterable, Identifiable {
    case manual = "Manual"
    case automatic = "Automatic"
    var id: String { rawValue }
}

@Model
final class Student {
    var name: String
    var phone: String
    var email: String
    var pickupAddress: String
    var postcode: String
    var licenceNumber: String
    var transmission: TransmissionType
    var hourlyRate: Double
    var theoryTestPassed: Bool
    var theoryTestDate: Date?
    var practicalTestDate: Date?
    var notes: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Lesson.student)
    var lessons: [Lesson] = []

    init(
        name: String = "",
        phone: String = "",
        email: String = "",
        pickupAddress: String = "",
        postcode: String = "",
        licenceNumber: String = "",
        transmission: TransmissionType = .manual,
        hourlyRate: Double = 35.0,
        theoryTestPassed: Bool = false,
        theoryTestDate: Date? = nil,
        practicalTestDate: Date? = nil,
        notes: String = ""
    ) {
        self.name = name
        self.phone = phone
        self.email = email
        self.pickupAddress = pickupAddress
        self.postcode = postcode
        self.licenceNumber = licenceNumber
        self.transmission = transmission
        self.hourlyRate = hourlyRate
        self.theoryTestPassed = theoryTestPassed
        self.theoryTestDate = theoryTestDate
        self.practicalTestDate = practicalTestDate
        self.notes = notes
        self.createdAt = Date()
    }

    var totalHours: Double {
        lessons.reduce(0) { $0 + $1.durationHours }
    }

    var completedLessonsCount: Int {
        lessons.filter { $0.date <= Date() }.count
    }

    var upcomingLessonsCount: Int {
        lessons.filter { $0.date > Date() }.count
    }

    var totalEarned: Double {
        lessons.filter { $0.paid }.reduce(0) { $0 + $1.amount }
    }

    var outstandingBalance: Double {
        lessons.filter { !$0.paid && $0.date <= Date() }.reduce(0) { $0 + $1.amount }
    }
}
