import SwiftUI
import SwiftData

@Observable
final class HabitManagementViewModel {
    var habits: [Habit] = []

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func loadHabits() {
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.isArchived == false },
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        habits = (try? modelContext.fetch(descriptor)) ?? []
    }

    func addHabit(name: String, icon: String, category: HabitCategory, xpReward: Int) {
        let habit = Habit(
            name: name,
            icon: icon,
            category: category,
            xpReward: xpReward,
            sortOrder: habits.count
        )
        modelContext.insert(habit)
        loadHabits()
    }

    func updateHabit(_ habit: Habit, name: String, icon: String, category: HabitCategory, xpReward: Int) {
        habit.name = name
        habit.icon = icon
        habit.category = category
        habit.xpReward = xpReward
        loadHabits()
    }

    func archiveHabit(_ habit: Habit) {
        habit.isArchived = true
        loadHabits()
    }

    func moveHabits(from source: IndexSet, to destination: Int) {
        habits.move(fromOffsets: source, toOffset: destination)
        for (index, habit) in habits.enumerated() {
            habit.sortOrder = index
        }
    }
}
