import Foundation
import SwiftData

@Model
final class Lesson {
    var date: Date
    var durationHours: Double
    var pickupLocation: String
    var dropoffLocation: String
    var topicsCovered: String
    var notes: String
    var amount: Double
    var paid: Bool
    var student: Student?

    init(
        date: Date = Date(),
        durationHours: Double = 1.0,
        pickupLocation: String = "",
        dropoffLocation: String = "",
        topicsCovered: String = "",
        notes: String = "",
        amount: Double = 35.0,
        paid: Bool = false,
        student: Student? = nil
    ) {
        self.date = date
        self.durationHours = durationHours
        self.pickupLocation = pickupLocation
        self.dropoffLocation = dropoffLocation
        self.topicsCovered = topicsCovered
        self.notes = notes
        self.amount = amount
        self.paid = paid
        self.student = student
    }

    var endDate: Date {
        date.addingTimeInterval(durationHours * 3600)
    }

    var isUpcoming: Bool {
        date > Date()
    }
}
