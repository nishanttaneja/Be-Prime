import SwiftUI
import SwiftData

@Observable
final class HunterCardViewModel {
    var profile: HunterProfile?
    var rank: HunterRank = .e
    var level: Int = 1
    var totalXP: Int = 0
    var xpProgress: (earned: Int, required: Int) = (0, 1)
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var totalDaysTracked: Int = 0
    var totalHabitsCompleted: Int = 0
    var totalPerfectDays: Int = 0
    var totalXPLost: Int = 0
    var powerLevel: Int = 0
    var isInPenaltyZone: Bool = false
    var unlockedAchievements: [Achievement] = []
    var lockedAchievements: [AchievementDefinition] = []

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func onAppear() {
        loadProfile()
        checkAndUnlockAchievements()
    }

    func loadProfile() {
        let descriptor = FetchDescriptor<HunterProfile>()
        guard let profile = try? modelContext.fetch(descriptor).first else { return }
        self.profile = profile

        rank = HunterRank.rank(forLevel: profile.currentLevel)
        level = profile.currentLevel
        totalXP = profile.totalXP
        xpProgress = GamificationEngine.xpProgressInCurrentLevel(totalXP: profile.totalXP)
        currentStreak = profile.currentStreak
        longestStreak = profile.longestStreak
        totalDaysTracked = profile.totalDaysTracked
        totalHabitsCompleted = profile.totalHabitsCompleted
        totalPerfectDays = profile.totalPerfectDays
        totalXPLost = profile.totalXPLost
        powerLevel = profile.powerLevel
        isInPenaltyZone = profile.isInPenaltyZone
        unlockedAchievements = profile.achievements.sorted { $0.unlockedAt > $1.unlockedAt }
    }

    func updateHunterName(_ name: String) {
        guard let profile else { return }
        profile.hunterName = name
    }

    func checkAndUnlockAchievements() {
        guard let profile else { return }
        let alreadyUnlocked = Set(profile.achievements.map(\.key))
        var newlyUnlocked: [AchievementDefinition] = []
        var locked: [AchievementDefinition] = []

        for def in AchievementDefinition.all {
            if alreadyUnlocked.contains(def.id) {
                continue
            }
            if def.condition(profile) {
                let achievement = Achievement(
                    key: def.id,
                    name: def.title,
                    detail: def.description,
                    icon: def.icon
                )
                achievement.profile = profile
                modelContext.insert(achievement)
                newlyUnlocked.append(def)
            } else {
                locked.append(def)
            }
        }

        lockedAchievements = locked
        if !newlyUnlocked.isEmpty {
            loadProfile()
        }
    }
}

// MARK: - Achievement Definitions

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let condition: (HunterProfile) -> Bool

    static let all: [AchievementDefinition] = [
        // Streak achievements
        .init(id: "streak_3", title: "Awakening", description: "3-day streak", icon: "sunrise.fill",
              condition: { $0.longestStreak >= 3 }),
        .init(id: "streak_7", title: "Gate Opener", description: "7-day streak", icon: "door.left.hand.open",
              condition: { $0.longestStreak >= 7 }),
        .init(id: "streak_14", title: "Dungeon Walker", description: "14-day streak", icon: "figure.walk",
              condition: { $0.longestStreak >= 14 }),
        .init(id: "streak_30", title: "Shadow Soldier", description: "30-day streak", icon: "person.fill",
              condition: { $0.longestStreak >= 30 }),
        .init(id: "streak_100", title: "Shadow Monarch", description: "100-day streak", icon: "crown.fill",
              condition: { $0.longestStreak >= 100 }),
        .init(id: "streak_365", title: "Absolute Being", description: "365-day streak", icon: "sparkles",
              condition: { $0.longestStreak >= 365 }),

        // Rank achievements
        .init(id: "rank_d", title: "D-Rank Awakened", description: "Reach D-Rank", icon: "d.circle.fill",
              condition: { $0.currentLevel >= 10 }),
        .init(id: "rank_c", title: "C-Rank Awakened", description: "Reach C-Rank", icon: "c.circle.fill",
              condition: { $0.currentLevel >= 25 }),
        .init(id: "rank_b", title: "B-Rank Awakened", description: "Reach B-Rank", icon: "b.circle.fill",
              condition: { $0.currentLevel >= 45 }),
        .init(id: "rank_a", title: "A-Rank Awakened", description: "Reach A-Rank", icon: "a.circle.fill",
              condition: { $0.currentLevel >= 70 }),
        .init(id: "rank_s", title: "National Level", description: "Reach S-Rank", icon: "s.circle.fill",
              condition: { $0.currentLevel >= 100 }),

        // Volume achievements
        .init(id: "habits_100", title: "Centurion", description: "Complete 100 habits", icon: "100.circle.fill",
              condition: { $0.totalHabitsCompleted >= 100 }),
        .init(id: "habits_1000", title: "Shadow Army", description: "Complete 1,000 habits", icon: "person.3.fill",
              condition: { $0.totalHabitsCompleted >= 1000 }),
        .init(id: "perfect_7", title: "Perfect Week", description: "7 perfect days", icon: "trophy.fill",
              condition: { $0.totalPerfectDays >= 7 }),
        .init(id: "perfect_30", title: "Perfect Month", description: "30 perfect days", icon: "medal.fill",
              condition: { $0.totalPerfectDays >= 30 }),

        // Penalty survival
        .init(id: "penalty_escape", title: "Penalty Escapee", description: "Escape the Penalty Zone", icon: "figure.walk.departure",
              condition: { $0.totalXPLost > 0 && !$0.isInPenaltyZone && $0.totalPerfectDays > 0 }),
    ]
}
