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
            return DailyResetResult(
                todayRecord: existing,
                penaltyApplied: nil,
                streakBroken: false,
                escapedPenaltyZone: false,
                isNewDay: false
            )
        }

        // New day — evaluate yesterday
        let yesterdayKey = Date().adding(days: -1).toDateKey()
        let yesterdayDescriptor = FetchDescriptor<DailyRecord>(
            predicate: #Predicate { $0.dateKey == yesterdayKey }
        )
        let yesterday = try? modelContext.fetch(yesterdayDescriptor).first

        var penaltyResult: PenaltyResult?
        var streakBroken = false
        var escapedPenaltyZone = false

        if let yesterday {
            if yesterday.allCompleted {
                // Perfect day — increment streak
                profile.currentStreak += 1
                profile.longestStreak = max(profile.longestStreak, profile.currentStreak)
                profile.totalPerfectDays += 1

                // Escape Penalty Zone on perfect day
                if profile.isInPenaltyZone {
                    profile.isInPenaltyZone = false
                    profile.penaltyZoneEnteredDate = nil
                    escapedPenaltyZone = true
                }
            } else {
                // Incomplete day — apply penalties
                let recentXP = fetchRecentDailyXP(modelContext: modelContext, days: 7)
                let result = PenaltyEngine.applyPenalty(
                    totalXP: profile.totalXP,
                    currentLevel: profile.currentLevel,
                    recentDailyXP: recentXP,
                    completedCount: yesterday.completedCount,
                    wasInPenaltyZone: profile.isInPenaltyZone
                )

                profile.totalXP = result.newTotalXP
                profile.currentLevel = result.newLevel
                profile.totalXPLost += result.xpLost
                profile.currentStreak = 0
                streakBroken = true

                if result.enteredPenaltyZone {
                    profile.isInPenaltyZone = true
                    profile.penaltyZoneEnteredDate = todayKey
                }

                yesterday.xpPenalty = result.xpLost
                penaltyResult = result
            }
        } else if profile.totalDaysTracked > 0 {
            // No record at all — fully skipped day
            let recentXP = fetchRecentDailyXP(modelContext: modelContext, days: 7)
            let result = PenaltyEngine.applyPenalty(
                totalXP: profile.totalXP,
                currentLevel: profile.currentLevel,
                recentDailyXP: recentXP,
                completedCount: 0,
                wasInPenaltyZone: profile.isInPenaltyZone
            )

            profile.totalXP = result.newTotalXP
            profile.currentLevel = result.newLevel
            profile.totalXPLost += result.xpLost
            profile.currentStreak = 0
            profile.isInPenaltyZone = true
            profile.penaltyZoneEnteredDate = todayKey
            streakBroken = true
            penaltyResult = result
        }

        profile.totalDaysTracked += 1
        profile.lastActiveDate = Date()

        // Count active habits
        let habitDescriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.isArchived == false }
        )
        let activeHabits = (try? modelContext.fetch(habitDescriptor)) ?? []

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
