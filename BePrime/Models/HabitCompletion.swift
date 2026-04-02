import Foundation
import SwiftData

@Model
final class HabitCompletion {
    var id: UUID
    var isCompleted: Bool
    var completedAt: Date?
    var xpAwarded: Int

    var habit: Habit?
    var dailyRecord: DailyRecord?

    init(habit: Habit, dailyRecord: DailyRecord) {
        self.id = UUID()
        self.isCompleted = false
        self.completedAt = nil
        self.xpAwarded = 0
        self.habit = habit
        self.dailyRecord = dailyRecord
    }
}
