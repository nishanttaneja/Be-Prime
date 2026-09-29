import Foundation
import SwiftData

@Model
final class DailyRecord {
    var id: UUID
    var dateKey: String
    var totalHabitsAvailable: Int
    var completedCount: Int
    var totalXPEarned: Int
    var xpPenalty: Int
    var allCompleted: Bool
    var wasInPenaltyZone: Bool
    /// Bonus actually credited for clearing the day; undo removes exactly this, never a recomputed value.
    var bonusXPAwarded: Int = 0

    @Relationship(deleteRule: .cascade, inverse: \HabitCompletion.dailyRecord)
    var completions: [HabitCompletion]

    init(dateKey: String, totalHabitsAvailable: Int) {
        self.id = UUID()
        self.dateKey = dateKey
        self.totalHabitsAvailable = totalHabitsAvailable
        self.completedCount = 0
        self.totalXPEarned = 0
        self.xpPenalty = 0
        self.allCompleted = false
        self.wasInPenaltyZone = false
        self.bonusXPAwarded = 0
        self.completions = []
    }
}
