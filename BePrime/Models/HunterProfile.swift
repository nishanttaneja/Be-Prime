import Foundation
import SwiftData

@Model
final class HunterProfile {
    var id: UUID
    var hunterName: String
    var totalXP: Int
    var currentLevel: Int
    var currentStreak: Int
    var longestStreak: Int
    var totalDaysTracked: Int
    var totalHabitsCompleted: Int
    var totalPerfectDays: Int
    var totalXPLost: Int
    var isInPenaltyZone: Bool
    var penaltyZoneEnteredDate: String?
    var joinedDate: Date
    var lastActiveDate: Date

    @Relationship(deleteRule: .cascade, inverse: \Achievement.profile)
    var achievements: [Achievement]

    var powerLevel: Int {
        (currentLevel * 100) + (currentStreak * 10) + (totalPerfectDays * 5)
    }

    init(hunterName: String = "Hunter") {
        self.id = UUID()
        self.hunterName = hunterName
        self.totalXP = 0
        self.currentLevel = 1
        self.currentStreak = 0
        self.longestStreak = 0
        self.totalDaysTracked = 0
        self.totalHabitsCompleted = 0
        self.totalPerfectDays = 0
        self.totalXPLost = 0
        self.isInPenaltyZone = false
        self.penaltyZoneEnteredDate = nil
        self.joinedDate = Date()
        self.lastActiveDate = Date()
        self.achievements = []
    }
}
