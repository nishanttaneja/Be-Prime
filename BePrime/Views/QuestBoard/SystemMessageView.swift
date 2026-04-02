import SwiftUI

struct SystemMessageView: View {
    let message: SystemMessage

    private var borderColor: Color {
        switch message.style {
        case .info: .systemBorder
        case .success: .xpGreen.opacity(0.6)
        case .warning: .xpGold.opacity(0.6)
        case .danger: .penaltyRed.opacity(0.6)
        }
    }

    private var glowColor: Color {
        switch message.style {
        case .info: .systemGlow
        case .success: .xpGreen.opacity(0.3)
        case .warning: .xpGold.opacity(0.3)
        case .danger: .penaltyGlow
        }
    }

    private var textColor: Color {
        switch message.style {
        case .info: .systemBlue
        case .success: .xpGreen
        case .warning: .xpGold
        case .danger: .penaltyRed
        }
    }

    var body: some View {
        Text(message.text)
            .font(.caption)
            .fontDesign(.monospaced)
            .foregroundColor(textColor)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor, lineWidth: 1)
                    )
                    .shadow(color: glowColor, radius: 6)
            )
    }
}
