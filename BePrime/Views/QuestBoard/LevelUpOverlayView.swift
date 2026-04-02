import SwiftUI

struct LevelUpOverlayView: View {
    let level: Int
    let rank: HunterRank?
    let isLevelDown: Bool
    let onDismiss: () -> Void

    @State private var showContent = false
    @State private var showDetails = false

    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            VStack(spacing: 24) {
                // Level change text
                Text(isLevelDown ? "LEVEL DOWN" : "LEVEL UP")
                    .font(.title)
                    .fontWeight(.black)
                    .fontDesign(.monospaced)
                    .foregroundStyle(isLevelDown ? .penaltyRed : .xpGold)
                    .shadow(color: isLevelDown ? .penaltyGlow : .xpGold.opacity(0.5), radius: 12)
                    .scaleEffect(showContent ? 1 : 0.3)
                    .opacity(showContent ? 1 : 0)

                // Level number
                Text("Lv. \(level)")
                    .font(.system(size: 64, weight: .heavy, design: .monospaced))
                    .foregroundStyle(isLevelDown ? .penaltyRed : .systemBlue)
                    .shadow(color: isLevelDown ? .penaltyGlow : .systemGlow, radius: 16)
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)

                // Rank info (if rank changed)
                if let rank, !isLevelDown {
                    VStack(spacing: 12) {
                        Text(rank.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(rank.color)
                            .shadow(color: rank.glowColor, radius: 8)

                        Text(rank.rankUpQuote)
                            .font(.subheadline)
                            .italic()
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .opacity(showDetails ? 1 : 0)
                    .offset(y: showDetails ? 0 : 20)
                }

                if isLevelDown {
                    Text("[System] Pain is the catalyst for growth. Rise again.")
                        .font(.subheadline)
                        .fontDesign(.monospaced)
                        .foregroundStyle(.penaltyRed.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(showDetails ? 1 : 0)
                }

                // Dismiss hint
                Text("Tap to continue")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.top, 16)
                    .opacity(showDetails ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                showContent = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
                showDetails = true
            }
        }
    }
}
