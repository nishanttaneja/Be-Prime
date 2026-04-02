import Testing
@testable import BePrime

@Suite("PenaltyEngine Tests")
struct PenaltyEngineTests {

    @Test("XP penalty is 10% of average clamped to min 25")
    func xpPenaltyBasic() {
        let penalty = PenaltyEngine.calculateXPPenalty(recentDailyXP: [300, 300, 300])
        #expect(penalty == 30)
    }

    @Test("XP penalty minimum is 25")
    func xpPenaltyMinimum() {
        let penalty = PenaltyEngine.calculateXPPenalty(recentDailyXP: [10, 10])
        #expect(penalty == 25)
    }

    @Test("XP penalty maximum is 500")
    func xpPenaltyMaximum() {
        let penalty = PenaltyEngine.calculateXPPenalty(recentDailyXP: [10000, 10000])
        #expect(penalty == 500)
    }

    @Test("Empty history gives minimum penalty")
    func xpPenaltyEmptyHistory() {
        let penalty = PenaltyEngine.calculateXPPenalty(recentDailyXP: [])
        #expect(penalty == 25)
    }

    @Test("Zero completions triggers Penalty Zone")
    func penaltyZoneActivates() {
        #expect(PenaltyEngine.shouldEnterPenaltyZone(completedCount: 0) == true)
    }

    @Test("Any completions does not trigger Penalty Zone")
    func penaltyZoneDoesNotActivate() {
        #expect(PenaltyEngine.shouldEnterPenaltyZone(completedCount: 1) == false)
    }

    @Test("Perfect day escapes Penalty Zone")
    func penaltyZoneEscape() {
        #expect(PenaltyEngine.canExitPenaltyZone(allCompleted: true) == true)
    }

    @Test("Incomplete day does not escape Penalty Zone")
    func penaltyZoneNoEscape() {
        #expect(PenaltyEngine.canExitPenaltyZone(allCompleted: false) == false)
    }

    @Test("Level-down occurs when XP drops below threshold")
    func levelDown() {
        // Level 10 requires 5400 XP
        let result = PenaltyEngine.applyPenalty(
            totalXP: 5400,
            currentLevel: 10,
            recentDailyXP: [5000], // 10% = 500 penalty
            completedCount: 1,
            wasInPenaltyZone: false
        )
        #expect(result.newTotalXP == 4900)
        #expect(result.newLevel == 9)
        #expect(result.leveledDown == true)
    }

    @Test("XP cannot go below zero")
    func xpFloor() {
        let result = PenaltyEngine.applyPenalty(
            totalXP: 10,
            currentLevel: 1,
            recentDailyXP: [300],
            completedCount: 0,
            wasInPenaltyZone: false
        )
        #expect(result.newTotalXP == 0)
        #expect(result.newLevel == 1)
    }

    @Test("Penalty multiplier is 0.5")
    func penaltyMultiplier() {
        #expect(PenaltyEngine.penaltyZoneMultiplier == 0.5)
    }
}
