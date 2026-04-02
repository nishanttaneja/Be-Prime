import SwiftUI

enum HunterRank: Int, CaseIterable, Comparable, Sendable {
    case e = 0
    case d = 1
    case c = 2
    case b = 3
    case a = 4
    case s = 5

    var title: String {
        switch self {
        case .e: "E-Rank Hunter"
        case .d: "D-Rank Hunter"
        case .c: "C-Rank Hunter"
        case .b: "B-Rank Hunter"
        case .a: "A-Rank Hunter"
        case .s: "S-Rank Hunter"
        }
    }

    var shortTitle: String {
        switch self {
        case .e: "E"
        case .d: "D"
        case .c: "C"
        case .b: "B"
        case .a: "A"
        case .s: "S"
        }
    }

    var minimumLevel: Int {
        switch self {
        case .e: 1
        case .d: 10
        case .c: 25
        case .b: 45
        case .a: 70
        case .s: 100
        }
    }

    var color: Color {
        switch self {
        case .e: .gray
        case .d: .green
        case .c: .blue
        case .b: .purple
        case .a: .orange
        case .s: .red
        }
    }

    var glowColor: Color {
        switch self {
        case .e: .gray.opacity(0.3)
        case .d: .green.opacity(0.4)
        case .c: .cyan.opacity(0.5)
        case .b: .purple.opacity(0.5)
        case .a: .orange.opacity(0.6)
        case .s: .yellow.opacity(0.7)
        }
    }

    var rankUpQuote: String {
        switch self {
        case .e: "The System has chosen you. Your journey begins now."
        case .d: "You've begun to awaken. The gates ahead grow larger."
        case .c: "Most hunters stop here. You are not most hunters."
        case .b: "Your shadow grows longer. Others are beginning to notice."
        case .a: "National-level power approaches. Few have walked this far."
        case .s: "You stand among the strongest. The Shadow Monarch's throne awaits."
        }
    }

    static func rank(forLevel level: Int) -> HunterRank {
        for rank in Self.allCases.reversed() {
            if level >= rank.minimumLevel { return rank }
        }
        return .e
    }

    static func < (lhs: HunterRank, rhs: HunterRank) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
