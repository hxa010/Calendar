import SwiftUI
import SwiftData

@main
struct DrivingInstructorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Student.self, Lesson.self])
    }
}
