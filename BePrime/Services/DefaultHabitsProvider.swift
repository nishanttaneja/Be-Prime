import Foundation
import SwiftData

struct DefaultHabitsProvider {
    static func seedDefaultHabits(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Habit>()
        let existingCount = (try? modelContext.fetchCount(descriptor)) ?? 0
        guard existingCount == 0 else { return }

        let defaults: [(String, String, HabitCategory, Int)] = [
            ("Drink 3L Water", "drop.fill", .nutrition, 50),
            ("Eat Healthy Meals", "fork.knife", .nutrition, 50),
            ("Exercise 30 Min", "figure.run", .fitness, 75),
            ("Sleep 8 Hours", "bed.double.fill", .discipline, 50),
            ("Meditate 10 Min", "brain.head.profile", .mind, 50),
        ]

        for (index, (name, icon, category, xp)) in defaults.enumerated() {
            let habit = Habit(
                name: name,
                icon: icon,
                category: category,
                xpReward: xp,
                sortOrder: index
            )
            modelContext.insert(habit)
        }
    }

    static func ensureProfileExists(modelContext: ModelContext) -> HunterProfile {
        let descriptor = FetchDescriptor<HunterProfile>()
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }
        let profile = HunterProfile()
        modelContext.insert(profile)
        return profile
    }
}
