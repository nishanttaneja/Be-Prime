import SwiftUI
import SwiftData

@main
struct BePrimeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Habit.self,
            HabitCompletion.self,
            DailyRecord.self,
            HunterProfile.self,
            Achievement.self
        ])
    }
}
