import SwiftUI

struct RankBadgeView: View {
    let rank: HunterRank
    var size: CGFloat = 60

    @State private var isGlowing = false

    var body: some View {
        ZStack {
            // Shield shape background
            Image(systemName: "shield.fill")
                .font(.system(size: size))
                .foregroundStyle(
                    LinearGradient(
                        colors: [rank.color, rank.color.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: rank.glowColor, radius: isGlowing ? 16 : 8)

            // Rank letter
            Text(rank.shortTitle)
                .font(.system(size: size * 0.4, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 2)
        }
        .onAppear {
            if rank == .s {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isGlowing = true
                }
            }
        }
    }
}
