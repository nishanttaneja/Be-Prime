import Foundation

struct PenaltyEngine {
    /// XP multiplier when in Penalty Zone
    static let penaltyZoneMultiplier: Double = 0.5

    /// Calculate XP penalty for an incomplete day.
    /// Penalty = 10% of average daily XP over recent days.
    /// Clamped to [25, 500].
    static func calculateXPPenalty(recentDailyXP: [Int]) -> Int {
        guard !recentDailyXP.isEmpty else { return 25 }
        let average = recentDailyXP.reduce(0, +) / recentDailyXP.count
        let penalty = max(25, min(500, average / 10))
        return penalty
    }

    /// Penalty Zone activates when a day has zero completions.
    static func shouldEnterPenaltyZone(completedCount: Int) -> Bool {
        completedCount == 0
    }

    /// Player exits Penalty Zone by completing all habits in a day.
    static func canExitPenaltyZone(allCompleted: Bool) -> Bool {
        allCompleted
    }

    /// Recalculate level after XP change (supports level-down).
    static func recalculateLevel(totalXP: Int) -> Int {
        GamificationEngine.level(forTotalXP: max(0, totalXP))
    }

    /// Apply penalty to profile, returning details of what happened.
    static func applyPenalty(
        totalXP: Int,
        currentLevel: Int,
        recentDailyXP: [Int],
        completedCount: Int,
        wasInPenaltyZone: Bool
    ) -> PenaltyResult {
        let xpLoss = calculateXPPenalty(recentDailyXP: recentDailyXP)
        let newTotalXP = max(0, totalXP - xpLoss)
        let newLevel = recalculateLevel(totalXP: newTotalXP)
        let leveledDown = newLevel < currentLevel
        let enterPenaltyZone = shouldEnterPenaltyZone(completedCount: completedCount)
        let nowInPenaltyZone = wasInPenaltyZone || enterPenaltyZone

        return PenaltyResult(
            xpLost: xpLoss,
            newTotalXP: newTotalXP,
            newLevel: newLevel,
            leveledDown: leveledDown,
            enteredPenaltyZone: enterPenaltyZone,
            isInPenaltyZone: nowInPenaltyZone
        )
    }
}

struct PenaltyResult {
    let xpLost: Int
    let newTotalXP: Int
    let newLevel: Int
    let leveledDown: Bool
    let enteredPenaltyZone: Bool
    let isInPenaltyZone: Bool
}
