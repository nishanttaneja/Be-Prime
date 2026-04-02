import Foundation

struct GamificationEngine {
    // MARK: - XP Rewards
    static let dungeonClearedBonus: Int = 100

    static func streakMultiplier(forStreak streak: Int) -> Double {
        switch streak {
        case 0...6: 1.0
        case 7...13: 1.25
        case 14...29: 1.5
        case 30...59: 2.0
        default: 2.5
        }
    }

    /// Calculate total XP for a day given completions and streak.
    /// `penaltyZoneActive` halves all XP and disables dungeon bonus.
    static func calculateDailyXP(
        completedHabits: [(xpReward: Int, completed: Bool)],
        currentStreak: Int,
        penaltyZoneActive: Bool
    ) -> Int {
        let baseXP = completedHabits
            .filter(\.completed)
            .reduce(0) { $0 + $1.xpReward }

        let effectiveBaseXP = penaltyZoneActive ? Int(Double(baseXP) * PenaltyEngine.penaltyZoneMultiplier) : baseXP

        let allCompleted = completedHabits.allSatisfy(\.completed) && !completedHabits.isEmpty

        guard allCompleted && !penaltyZoneActive else { return effectiveBaseXP }

        let multiplier = streakMultiplier(forStreak: currentStreak)
        let bonus = Int(Double(dungeonClearedBonus) * multiplier)
        return effectiveBaseXP + bonus
    }

    // MARK: - Leveling

    /// Cumulative XP to REACH a given level.
    /// Formula: 50 * (level - 1) * (level + 2)
    static func cumulativeXPRequired(forLevel level: Int) -> Int {
        guard level > 1 else { return 0 }
        return 50 * (level - 1) * (level + 2)
    }

    /// XP needed to go from current level to next level.
    static func xpRequiredForNextLevel(currentLevel: Int) -> Int {
        cumulativeXPRequired(forLevel: currentLevel + 1) - cumulativeXPRequired(forLevel: currentLevel)
    }

    /// Determine level from total XP using binary search.
    static func level(forTotalXP xp: Int) -> Int {
        guard xp > 0 else { return 1 }
        var lo = 1, hi = 500
        while lo < hi {
            let mid = (lo + hi + 1) / 2
            if cumulativeXPRequired(forLevel: mid) <= xp {
                lo = mid
            } else {
                hi = mid - 1
            }
        }
        return max(1, lo)
    }

    /// Progress within the current level: (earned towards next, required for next).
    static func xpProgressInCurrentLevel(totalXP: Int) -> (earned: Int, required: Int) {
        let lvl = level(forTotalXP: totalXP)
        let base = cumulativeXPRequired(forLevel: lvl)
        let next = cumulativeXPRequired(forLevel: lvl + 1)
        return (totalXP - base, next - base)
    }

    /// Rank for a given total XP.
    static func rank(forTotalXP xp: Int) -> HunterRank {
        HunterRank.rank(forLevel: level(forTotalXP: xp))
    }
}
