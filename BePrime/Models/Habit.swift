import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var name: String
    var icon: String
    var categoryRaw: String
    var xpReward: Int
    var sortOrder: Int
    var isArchived: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \HabitCompletion.habit)
    var completions: [HabitCompletion]

    var category: HabitCategory {
        get { HabitCategory(rawValue: categoryRaw) ?? .general }
        set { categoryRaw = newValue.rawValue }
    }

    init(
        name: String,
        icon: String = "star.fill",
        category: HabitCategory = .general,
        xpReward: Int = 50,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.categoryRaw = category.rawValue
        self.xpReward = xpReward
        self.sortOrder = sortOrder
        self.isArchived = false
        self.createdAt = Date()
        self.completions = []
    }
}
