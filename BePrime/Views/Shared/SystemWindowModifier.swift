import SwiftUI

struct SystemWindowModifier: ViewModifier {
    var isInPenaltyZone: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isInPenaltyZone ? Color.penaltyRed.opacity(0.6) : Color.systemBorder,
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: isInPenaltyZone ? .penaltyGlow : .systemGlow,
                        radius: 8,
                        x: 0,
                        y: 0
                    )
            )
    }
}

extension View {
    func systemWindow(penaltyZone: Bool = false) -> some View {
        modifier(SystemWindowModifier(isInPenaltyZone: penaltyZone))
    }
}
