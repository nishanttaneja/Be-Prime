import Foundation

struct SystemMessageProvider {
    static func message(
        completedCount: Int,
        totalCount: Int,
        currentStreak: Int,
        isInPenaltyZone: Bool,
        penaltyApplied: PenaltyResult?,
        escapedPenaltyZone: Bool
    ) -> SystemMessage {
        // Priority: penalty events > penalty zone > streak milestones > progress
        if let penalty = penaltyApplied {
            if penalty.leveledDown {
                return SystemMessage(
                    text: "[System] Level decreased. Pain is the catalyst for growth. Rise again.",
                    style: .danger
                )
            }
            if penalty.enteredPenaltyZone {
                return SystemMessage(
                    text: "[System] WARNING: You have entered the Penalty Zone. Complete all daily quests to escape.",
                    style: .danger
                )
            }
            return SystemMessage(
                text: "[System] Penalty: Daily quest incomplete. -\(penalty.xpLost) XP.",
                style: .warning
            )
        }

        if escapedPenaltyZone {
            return SystemMessage(
                text: "[System] You have survived the Penalty Zone. Emerge stronger.",
                style: .success
            )
        }

        if isInPenaltyZone {
            return SystemMessage(
                text: "[System] PENALTY ZONE ACTIVE. All XP halved. Complete all quests to escape.",
                style: .danger
            )
        }

        // Streak milestones
        if [3, 7, 14, 30, 100, 365].contains(currentStreak) {
            return streakMilestoneMessage(streak: currentStreak)
        }

        // Progress-based messages
        if totalCount == 0 {
            return SystemMessage(
                text: "[System] No quests configured. Add daily quests to begin.",
                style: .info
            )
        }

        if completedCount == 0 {
            return SystemMessage(
                text: "[System] A new dungeon has appeared. Will you rise to the challenge, Hunter?",
                style: .info
            )
        }

        if completedCount == totalCount {
            return SystemMessage(
                text: "[System] Dungeon Cleared. You have proven yourself worthy today.",
                style: .success
            )
        }

        let remaining = totalCount - completedCount
        return SystemMessage(
            text: "[System] You are growing stronger. \(remaining) quest\(remaining == 1 ? "" : "s") remain.",
            style: .info
        )
    }

    private static func streakMilestoneMessage(streak: Int) -> SystemMessage {
        let text: String
        switch streak {
        case 3: text = "[System] 3-day streak. The Awakening begins."
        case 7: text = "[System] 7-day streak. A Gate has opened \u{2014} and you walked through."
        case 14: text = "[System] 14-day streak. You've cleared dungeons others fear to enter."
        case 30: text = "[System] 30-day streak. A Shadow Soldier rises. Your discipline is your army."
        case 100: text = "[System] 100-day streak. The Shadow Monarch commands. Your will is unbreakable."
        case 365: text = "[System] 365-day streak. You have become an Absolute Being. None can match your resolve."
        default: text = "[System] \(streak)-day streak. Keep pushing forward, Hunter."
        }
        return SystemMessage(text: text, style: .success)
    }
}

struct SystemMessage: Equatable {
    let text: String
    let style: MessageStyle

    enum MessageStyle {
        case info
        case success
        case warning
        case danger
    }
}
