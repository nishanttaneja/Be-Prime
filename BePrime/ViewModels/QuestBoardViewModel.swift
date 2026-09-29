import SwiftUI
import SwiftData

@Observable
final class QuestBoardViewModel {
    var todayRecord: DailyRecord?
    var profile: HunterProfile?
    var questItems: [QuestItem] = []
    var dailyXPEarned: Int = 0
    var totalXP: Int = 0
    var currentLevel: Int = 1
    var currentRank: HunterRank = .e
    var xpProgress: (earned: Int, required: Int) = (0, 1)
    var currentStreak: Int = 0
    var isInPenaltyZone: Bool = false
    var systemMessage: SystemMessage = SystemMessage(text: "", style: .info)

    // Overlay states
    var showLevelUpOverlay: Bool = false
    var showLevelDownOverlay: Bool = false
    var newLevel: Int = 1
    var newRank: HunterRank?
    var showStreakCelebration: Bool = false
    var streakMilestone: Int = 0

    // Reset event state
    var penaltyApplied: PenaltyResult?
    var escapedPenaltyZone: Bool = false

    struct QuestItem: Identifiable {
        let id: UUID
        let habitName: String
        let habitIcon: String
        let category: HabitCategory
        let xpReward: Int
        var isCompleted: Bool
        let completion: HabitCompletion
    }

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func onAppear() {
        // Ensure profile and default habits exist
        let profile = DefaultHabitsProvider.ensureProfileExists(modelContext: modelContext)
        DefaultHabitsProvider.seedDefaultHabits(modelContext: modelContext)
        self.profile = profile

        // Daily reset (also syncs any new/archived habits into today's record)
        let resetResult = DailyResetService.ensureTodayRecord(
            modelContext: modelContext,
            profile: profile
        )

        todayRecord = resetResult.todayRecord

        // Only show penalty overlays on actual new day transitions
        if resetResult.isNewDay {
            penaltyApplied = resetResult.penaltyApplied
            escapedPenaltyZone = resetResult.escapedPenaltyZone

            if let penalty = resetResult.penaltyApplied, penalty.leveledDown {
                showLevelDownOverlay = true
                newLevel = penalty.newLevel
            }
        }

        loadQuests()
        updateProfileState()
        updateSystemMessage()
    }

    func loadQuests() {
        guard let record = todayRecord else { return }
        // Re-fetch the record's completions to pick up any newly synced habits
        questItems = record.completions
            .compactMap { completion in
                guard let habit = completion.habit, !habit.isArchived else { return nil }
                return QuestItem(
                    id: completion.id,
                    habitName: habit.name,
                    habitIcon: habit.icon,
                    category: habit.category,
                    xpReward: habit.xpReward,
                    isCompleted: completion.isCompleted,
                    completion: completion
                )
            }
            .sorted { ($0.completion.habit?.sortOrder ?? 0) < ($1.completion.habit?.sortOrder ?? 0) }
    }

    func toggleQuest(_ item: QuestItem) {
        guard let profile, let record = todayRecord else { return }

        let completion = item.completion
        let wasAllComplete = record.allCompleted
        let previousLevel = profile.currentLevel
        let previousRank = GamificationEngine.rank(forTotalXP: profile.totalXP)

        if completion.isCompleted {
            // Undo completion
            let xpToRemove = completion.xpAwarded
            completion.isCompleted = false
            completion.completedAt = nil
            completion.xpAwarded = 0

            profile.totalXP = max(0, profile.totalXP - xpToRemove)
            profile.totalHabitsCompleted -= 1
            record.completedCount -= 1
            record.totalXPEarned -= xpToRemove

            // Remove whatever bonus was actually credited (none in Penalty Zone)
            if wasAllComplete, record.bonusXPAwarded > 0 {
                let bonus = record.bonusXPAwarded
                profile.totalXP = max(0, profile.totalXP - bonus)
                record.totalXPEarned = max(0, record.totalXPEarned - bonus)
                record.bonusXPAwarded = 0
            }

            record.allCompleted = false
        } else {
            // Complete the quest
            let effectiveXP: Int
            if isInPenaltyZone {
                effectiveXP = Int(Double(item.xpReward) * PenaltyEngine.penaltyZoneMultiplier)
            } else {
                effectiveXP = item.xpReward
            }

            completion.isCompleted = true
            completion.completedAt = Date()
            completion.xpAwarded = effectiveXP

            profile.totalXP += effectiveXP
            profile.totalHabitsCompleted += 1
            record.completedCount += 1
            record.totalXPEarned += effectiveXP

            // Check if all active quests now complete (exclude archived habits)
            let activeCompletions = record.completions.filter { $0.habit?.isArchived == false }
            let allDone = !activeCompletions.isEmpty && activeCompletions.allSatisfy(\.isCompleted)
            if allDone {
                record.allCompleted = true
                // Bonus is credited once per day, even if a habit is added after a clear
                if !isInPenaltyZone, record.bonusXPAwarded == 0 {
                    let bonus = calculateDungeonBonus()
                    profile.totalXP += bonus
                    record.totalXPEarned += bonus
                    record.bonusXPAwarded = bonus
                }
            }
        }

        // Recalculate level
        profile.currentLevel = GamificationEngine.level(forTotalXP: profile.totalXP)

        // Check for level-up
        if profile.currentLevel > previousLevel {
            newLevel = profile.currentLevel
            let newRankValue = GamificationEngine.rank(forTotalXP: profile.totalXP)
            if newRankValue > previousRank {
                newRank = newRankValue
            } else {
                newRank = nil
            }
            showLevelUpOverlay = true
        }

        loadQuests()
        updateProfileState()
        updateSystemMessage()
    }

    private func calculateDungeonBonus() -> Int {
        guard let profile else { return 0 }
        let multiplier = GamificationEngine.streakMultiplier(forStreak: profile.currentStreak)
        return Int(Double(GamificationEngine.dungeonClearedBonus) * multiplier)
    }

    private func updateProfileState() {
        guard let profile else { return }
        totalXP = profile.totalXP
        currentLevel = profile.currentLevel
        currentRank = GamificationEngine.rank(forTotalXP: profile.totalXP)
        xpProgress = GamificationEngine.xpProgressInCurrentLevel(totalXP: profile.totalXP)
        currentStreak = profile.currentStreak
        isInPenaltyZone = profile.isInPenaltyZone
        dailyXPEarned = todayRecord?.totalXPEarned ?? 0
    }

    private func updateSystemMessage() {
        guard let record = todayRecord else { return }
        // Use questItems count as the live source of truth for active quests
        let completedCount = questItems.filter(\.isCompleted).count
        let totalCount = questItems.count
        systemMessage = SystemMessageProvider.message(
            completedCount: completedCount,
            totalCount: totalCount,
            currentStreak: currentStreak,
            isInPenaltyZone: isInPenaltyZone,
            penaltyApplied: penaltyApplied,
            escapedPenaltyZone: escapedPenaltyZone
        )
    }
}
