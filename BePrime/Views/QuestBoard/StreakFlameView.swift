import SwiftUI

struct StreakFlameView: View {
    let streak: Int

    private var flameIcon: String {
        streak >= 30 ? "flame.fill" : "flame"
    }

    private var flameColor: Color {
        switch streak {
        case 0: .gray.opacity(0.3)
        case 1...6: .flameOrange
        case 7...13: .flameOrange
        case 14...29: .flameBlue
        case 30...59: .flamePurple
        default: .flameShadow
        }
    }

    private var glowColor: Color {
        switch streak {
        case 0...6: .clear
        case 7...13: .flameOrange.opacity(0.4)
        case 14...29: .flameBlue.opacity(0.5)
        case 30...59: .flamePurple.opacity(0.5)
        default: .flameShadow.opacity(0.6)
        }
    }

    private var flameSize: CGFloat {
        switch streak {
        case 0: 16
        case 1...6: 20
        case 7...13: 24
        case 14...29: 28
        case 30...59: 32
        default: 36
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: flameIcon)
                .font(.system(size: flameSize))
                .foregroundColor(flameColor)
                .shadow(color: glowColor, radius: streak >= 7 ? 8 : 0)
                .symbolEffect(.pulse, isActive: streak >= 14)

            Text("\(streak)")
                .font(.headline)
                .fontDesign(.monospaced)
                .foregroundColor(flameColor)
        }
    }
}
