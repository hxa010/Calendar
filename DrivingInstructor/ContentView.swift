import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "square.grid.2x2") }

            StudentsView()
                .tabItem { Label("Students", systemImage: "person.2") }

            LessonsView()
                .tabItem { Label("Lessons", systemImage: "calendar") }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Student.self, Lesson.self], inMemory: true)
}
