import SwiftData
import Foundation

@MainActor
let previewContainer: ModelContainer = {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Habit.self, HabitCompletion.self, DailyRecord.self, HunterProfile.self, Achievement.self,
        configurations: config
    )
    let context = container.mainContext

    // Seed habits
    let habits = [
        Habit(name: "Drink 3L Water", icon: "drop.fill", category: .nutrition, xpReward: 50, sortOrder: 0),
        Habit(name: "Eat Healthy Meals", icon: "fork.knife", category: .nutrition, xpReward: 50, sortOrder: 1),
        Habit(name: "Exercise 30 Min", icon: "figure.run", category: .fitness, xpReward: 75, sortOrder: 2),
        Habit(name: "Sleep 8 Hours", icon: "bed.double.fill", category: .discipline, xpReward: 50, sortOrder: 3),
        Habit(name: "Meditate 10 Min", icon: "brain.head.profile", category: .mind, xpReward: 50, sortOrder: 4),
    ]
    habits.forEach { context.insert($0) }

    // Seed profile
    let profile = HunterProfile(hunterName: "Shadow Hunter")
    profile.totalXP = 6800
    profile.currentLevel = 15
    profile.currentStreak = 8
    profile.longestStreak = 14
    profile.totalDaysTracked = 30
    profile.totalHabitsCompleted = 120
    profile.totalPerfectDays = 18
    profile.totalXPLost = 150
    context.insert(profile)

    // Seed some achievements
    let achievement1 = Achievement(key: "streak_3", name: "Awakening", detail: "3-day streak", icon: "sunrise.fill")
    achievement1.profile = profile
    context.insert(achievement1)

    let achievement2 = Achievement(key: "streak_7", name: "Gate Opener", detail: "7-day streak", icon: "door.left.hand.open")
    achievement2.profile = profile
    context.insert(achievement2)

    // Seed daily records for last 14 days
    for offset in (1...14).reversed() {
        let date = Date().adding(days: -offset)
        let record = DailyRecord(dateKey: date.toDateKey(), totalHabitsAvailable: 5)
        let completed = min(5, Int.random(in: 2...5))
        record.completedCount = completed
        record.allCompleted = completed == 5
        record.totalXPEarned = completed * 50 + (completed == 5 ? 100 : 0)
        context.insert(record)

        for (index, habit) in habits.enumerated() {
            let completion = HabitCompletion(habit: habit, dailyRecord: record)
            completion.isCompleted = index < completed
            if completion.isCompleted {
                completion.completedAt = date
                completion.xpAwarded = habit.xpReward
            }
            context.insert(completion)
        }
    }

    // Today's record
    let today = DailyRecord(dateKey: Date().toDateKey(), totalHabitsAvailable: 5)
    today.completedCount = 2
    today.totalXPEarned = 100
    context.insert(today)

    for (index, habit) in habits.enumerated() {
        let completion = HabitCompletion(habit: habit, dailyRecord: today)
        completion.isCompleted = index < 2
        if completion.isCompleted {
            completion.completedAt = Date()
            completion.xpAwarded = habit.xpReward
        }
        context.insert(completion)
    }

    return container
}()
