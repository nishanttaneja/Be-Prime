import Testing
@testable import BePrime

@Suite("GamificationEngine Tests")
struct GamificationEngineTests {

    // MARK: - Cumulative XP

    @Test("Level 1 requires 0 XP")
    func level1RequiresZeroXP() {
        #expect(GamificationEngine.cumulativeXPRequired(forLevel: 1) == 0)
    }

    @Test("Level 2 requires 200 XP")
    func level2Requires200XP() {
        #expect(GamificationEngine.cumulativeXPRequired(forLevel: 2) == 200)
    }

    @Test("Level 10 requires 5400 XP")
    func level10() {
        #expect(GamificationEngine.cumulativeXPRequired(forLevel: 10) == 5400)
    }

    @Test("Level 100 requires 504900 XP")
    func level100() {
        #expect(GamificationEngine.cumulativeXPRequired(forLevel: 100) == 504900)
    }

    // MARK: - Level from XP

    @Test("0 XP is level 1")
    func zeroXPIsLevel1() {
        #expect(GamificationEngine.level(forTotalXP: 0) == 1)
    }

    @Test("199 XP is still level 1")
    func justBelowLevel2() {
        #expect(GamificationEngine.level(forTotalXP: 199) == 1)
    }

    @Test("200 XP is level 2")
    func exactlyLevel2() {
        #expect(GamificationEngine.level(forTotalXP: 200) == 2)
    }

    @Test("5400 XP is level 10 (D-Rank threshold)")
    func level10FromXP() {
        #expect(GamificationEngine.level(forTotalXP: 5400) == 10)
    }

    // MARK: - Rank

    @Test("Level 1 is E-Rank")
    func eRank() {
        #expect(HunterRank.rank(forLevel: 1) == .e)
    }

    @Test("Level 10 is D-Rank")
    func dRank() {
        #expect(HunterRank.rank(forLevel: 10) == .d)
    }

    @Test("Level 25 is C-Rank")
    func cRank() {
        #expect(HunterRank.rank(forLevel: 25) == .c)
    }

    @Test("Level 45 is B-Rank")
    func bRank() {
        #expect(HunterRank.rank(forLevel: 45) == .b)
    }

    @Test("Level 70 is A-Rank")
    func aRank() {
        #expect(HunterRank.rank(forLevel: 70) == .a)
    }

    @Test("Level 100 is S-Rank")
    func sRank() {
        #expect(HunterRank.rank(forLevel: 100) == .s)
    }

    // MARK: - Streak Multiplier

    @Test("No streak gives 1.0x")
    func noStreakMultiplier() {
        #expect(GamificationEngine.streakMultiplier(forStreak: 0) == 1.0)
    }

    @Test("7-day streak gives 1.25x")
    func weekStreakMultiplier() {
        #expect(GamificationEngine.streakMultiplier(forStreak: 7) == 1.25)
    }

    @Test("30-day streak gives 2.0x")
    func monthStreakMultiplier() {
        #expect(GamificationEngine.streakMultiplier(forStreak: 30) == 2.0)
    }

    @Test("60+ day streak gives 2.5x")
    func longStreakMultiplier() {
        #expect(GamificationEngine.streakMultiplier(forStreak: 60) == 2.5)
    }

    // MARK: - Daily XP Calculation

    @Test("All habits complete with no streak gives base + 100 bonus")
    func allCompleteNoStreak() {
        let habits = [(xpReward: 50, completed: true), (xpReward: 50, completed: true)]
        let xp = GamificationEngine.calculateDailyXP(completedHabits: habits, currentStreak: 0, penaltyZoneActive: false)
        #expect(xp == 200) // 100 base + 100 bonus
    }

    @Test("Partial completion gives no bonus")
    func partialCompletion() {
        let habits = [(xpReward: 50, completed: true), (xpReward: 50, completed: false)]
        let xp = GamificationEngine.calculateDailyXP(completedHabits: habits, currentStreak: 5, penaltyZoneActive: false)
        #expect(xp == 50) // Only the completed one
    }

    @Test("Penalty zone halves XP and disables bonus")
    func penaltyZoneXP() {
        let habits = [(xpReward: 50, completed: true), (xpReward: 50, completed: true)]
        let xp = GamificationEngine.calculateDailyXP(completedHabits: habits, currentStreak: 0, penaltyZoneActive: true)
        #expect(xp == 50) // 100 * 0.5 = 50, no bonus
    }

    // MARK: - XP Progress

    @Test("Progress at exactly level boundary shows 0 earned")
    func progressAtBoundary() {
        let progress = GamificationEngine.xpProgressInCurrentLevel(totalXP: 200) // Exactly level 2
        #expect(progress.earned == 0)
        #expect(progress.required == 300) // Level 2->3 requires 300
    }
}
