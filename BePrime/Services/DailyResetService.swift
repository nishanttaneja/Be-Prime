import Foundation
import SwiftData

struct DailyResetResult {
    var todayRecord: DailyRecord
    var penaltyApplied: PenaltyResult?
    var streakBroken: Bool
    var escapedPenaltyZone: Bool
    var isNewDay: Bool
}

struct DailyResetService {
    static func ensureTodayRecord(
        modelContext: ModelContext,
        profile: HunterProfile
    ) -> DailyResetResult {
        let todayKey = Date().toDateKey()

        // Check if today's record already exists
        let descriptor = FetchDescriptor<DailyRecord>(
            predicate: #Predicate { $0.dateKey == todayKey }
        )
        if let existing = try? modelContext.fetch(descriptor).first {
            // Sync habits — add completions for newly added habits, remove for archived ones
            syncHabitsWithRecord(existing, modelContext: modelContext)
            return DailyResetResult(
                todayRecord: existing,
                penaltyApplied: nil,
                streakBroken: false,
                escapedPenaltyZone: false,
                isNewDay: false
            )
        }

        // Count active habits
        let habitDescriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.isArchived == false }
        )
        let activeHabits = (try? modelContext.fetch(habitDescriptor)) ?? []

        // New day — evaluate every day since the last one we tracked, not only yesterday,
        // so a multi-day gap gets a record per day and the charts/day counts stay honest.
        var penaltyResult: PenaltyResult?
        var streakBroken = false
        let wasInPenaltyZone = profile.isInPenaltyZone

        if profile.totalDaysTracked > 0 {
            for dayKey in missedDayKeys(since: profile.lastActiveDate, todayKey: todayKey) {
                let record = fetchRecord(dateKey: dayKey, modelContext: modelContext)
                    ?? backfillRecord(dateKey: dayKey, activeHabitCount: activeHabits.count, modelContext: modelContext)

                if let penalty = evaluate(record, profile: profile, todayKey: todayKey, modelContext: modelContext) {
                    penaltyResult = penalty
                    streakBroken = true
                }
                profile.totalDaysTracked += 1
            }
        }
        let escapedPenaltyZone = wasInPenaltyZone && !profile.isInPenaltyZone

        profile.totalDaysTracked += 1
        profile.lastActiveDate = Date()

        // Create today's record
        let newRecord = DailyRecord(dateKey: todayKey, totalHabitsAvailable: activeHabits.count)
        newRecord.wasInPenaltyZone = profile.isInPenaltyZone
        modelContext.insert(newRecord)

        // Create HabitCompletion for each active habit
        for habit in activeHabits {
            let completion = HabitCompletion(habit: habit, dailyRecord: newRecord)
            modelContext.insert(completion)
        }

        return DailyResetResult(
            todayRecord: newRecord,
            penaltyApplied: penaltyResult,
            streakBroken: streakBroken,
            escapedPenaltyZone: escapedPenaltyZone,
            isNewDay: true
        )
    }

    /// Sync today's record with current active habits:
    /// - Add HabitCompletion for any new active habit not yet in today's record
    /// - Remove HabitCompletion for any archived habit (only if not yet completed)
    /// - Update totalHabitsAvailable to reflect current active count
    static func syncHabitsWithRecord(_ record: DailyRecord, modelContext: ModelContext) {
        let habitDescriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.isArchived == false }
        )
        let activeHabits = (try? modelContext.fetch(habitDescriptor)) ?? []
        let activeHabitIDs = Set(activeHabits.map(\.id))

        // Find which habits already have completions in today's record
        let existingHabitIDs = Set(record.completions.compactMap { $0.habit?.id })

        // Add completions for newly added habits
        for habit in activeHabits where !existingHabitIDs.contains(habit.id) {
            let completion = HabitCompletion(habit: habit, dailyRecord: record)
            modelContext.insert(completion)
        }

        // Remove completions for archived habits (only uncompleted ones)
        for completion in record.completions {
            guard let habit = completion.habit else { continue }
            if !activeHabitIDs.contains(habit.id) && !completion.isCompleted {
                modelContext.delete(completion)
            }
        }

        // Update counts
        let activeCompletions = record.completions.filter { completion in
            guard let habit = completion.habit else { return false }
            return activeHabitIDs.contains(habit.id)
        }
        record.totalHabitsAvailable = activeHabits.count
        record.completedCount = activeCompletions.filter(\.isCompleted).count
        record.allCompleted = record.completedCount == record.totalHabitsAvailable
            && record.totalHabitsAvailable > 0
    }

    /// Date keys for every calendar day after `lastActive` and before today, oldest first.
    /// Capped so a very long absence can't loop for thousands of days.
    static func missedDayKeys(since lastActive: Date, todayKey: String, maxDays: Int = 365) -> [String] {
        var keys: [String] = []
        var day = lastActive.startOfDay.adding(days: 1)
        while day.toDateKey() < todayKey && keys.count < maxDays {
            keys.append(day.toDateKey())
            day = day.adding(days: 1)
        }
        return keys
    }

    private static func fetchRecord(dateKey: String, modelContext: ModelContext) -> DailyRecord? {
        let descriptor = FetchDescriptor<DailyRecord>(
            predicate: #Predicate { $0.dateKey == dateKey }
        )
        return try? modelContext.fetch(descriptor).first
    }

    /// A day the app was never opened: record it with zero completions so charts show the gap.
    private static func backfillRecord(dateKey: String, activeHabitCount: Int, modelContext: ModelContext) -> DailyRecord {
        let record = DailyRecord(dateKey: dateKey, totalHabitsAvailable: activeHabitCount)
        modelContext.insert(record)
        return record
    }

    /// Apply the streak/penalty outcome of one finished day to the profile.
    /// Returns the penalty if one was applied. A day with no habits to do is neutral.
    private static func evaluate(
        _ record: DailyRecord,
        profile: HunterProfile,
        todayKey: String,
        modelContext: ModelContext
    ) -> PenaltyResult? {
        guard record.totalHabitsAvailable > 0 else { return nil }

        if record.allCompleted {
            profile.currentStreak += 1
            profile.longestStreak = max(profile.longestStreak, profile.currentStreak)
            profile.totalPerfectDays += 1
            if profile.isInPenaltyZone {
                profile.isInPenaltyZone = false
                profile.penaltyZoneEnteredDate = nil
            }
            return nil
        }

        let recentXP = fetchRecentDailyXP(modelContext: modelContext, days: 7)
        let result = PenaltyEngine.applyPenalty(
            totalXP: profile.totalXP,
            currentLevel: profile.currentLevel,
            recentDailyXP: recentXP,
            completedCount: record.completedCount,
            wasInPenaltyZone: profile.isInPenaltyZone
        )
        profile.totalXP = result.newTotalXP
        profile.currentLevel = result.newLevel
        profile.totalXPLost += result.xpLost
        profile.currentStreak = 0
        if result.enteredPenaltyZone && !profile.isInPenaltyZone {
            profile.isInPenaltyZone = true
            profile.penaltyZoneEnteredDate = todayKey
        }
        record.xpPenalty = result.xpLost
        return result
    }

    private static func fetchRecentDailyXP(modelContext: ModelContext, days: Int) -> [Int] {
        let cutoffKey = Date().adding(days: -days).toDateKey()
        let descriptor = FetchDescriptor<DailyRecord>(
            predicate: #Predicate { $0.dateKey >= cutoffKey },
            sortBy: [SortDescriptor(\.dateKey, order: .reverse)]
        )
        let records = (try? modelContext.fetch(descriptor)) ?? []
        return records.map(\.totalXPEarned)
    }
}
