# Driving Instructor

A native iOS app (SwiftUI + SwiftData) for UK driving instructors to track
students, lessons, hours, locations, and payments.

## Features

- **Dashboard** – at-a-glance student count, hours this week, earnings this
  month, outstanding balance, and today's / upcoming lessons.
- **Students** – full profile per student: contact, pickup address + postcode,
  provisional licence number, transmission (manual / auto), hourly rate,
  theory / practical test dates, free-form notes.
  - Tap phone / email / address to call, email, or open in Apple Maps.
- **Lessons** – book lessons with date, duration (0.5h steps), pickup and
  drop-off, topics covered (quick-add chips for common UK driving topics),
  notes, amount, and paid status. Amount auto-calculates from the student's
  hourly rate.
- **Per-student stats** – total hours, completed lessons, total paid,
  outstanding balance.
- **Filtering** – search students by name / postcode / phone; filter lessons
  by all / upcoming / past / unpaid.
- **Persistence** – SwiftData (local, on-device). No account needed.

## Requirements

- Xcode 15+
- iOS 17+ (SwiftData)
- Swift 5.9+

## Setup

This repo contains Swift source files only — no `.xcodeproj`. Create the
Xcode project on your Mac and drop these files in:

1. Open Xcode → **File ▸ New ▸ Project…**
2. Choose **iOS ▸ App**.
3. Name it `DrivingInstructor`.
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None** (we add SwiftData manually)
4. Save the project anywhere (e.g. `~/Developer/DrivingInstructor`).
5. In Finder, delete the template files Xcode generated:
   `DrivingInstructorApp.swift` and `ContentView.swift`.
6. Drag the `DrivingInstructor/` folder from this repo into the Xcode
   project navigator. Choose **Copy items if needed** and
   **Create groups**.
7. Select the project → target → **Info** tab and add usage strings if you
   later add location tracking:
   - `NSLocationWhenInUseUsageDescription`
8. Build & run on the iOS Simulator or your iPhone.

## Project structure

```
DrivingInstructor/
├── DrivingInstructorApp.swift   # App entry, SwiftData container
├── ContentView.swift            # Root TabView
├── Models/
│   ├── Student.swift
│   └── Lesson.swift
├── Views/
│   ├── DashboardView.swift
│   ├── StudentsView.swift
│   ├── StudentDetailView.swift
│   ├── StudentFormView.swift
│   ├── LessonsView.swift
│   └── LessonFormView.swift
└── Extensions/
    └── Formatters.swift         # £ and hours formatting (en_GB)
```

## Ideas for later

- iCloud sync via SwiftData + CloudKit
- Calendar / EventKit integration so lessons appear in the iOS Calendar
- Home Screen widget for next lesson
- Export earnings as CSV for accounting
- Route planning between back-to-back lessons
- In-app signature capture for lesson sign-offs
