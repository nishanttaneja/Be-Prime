import SwiftUI

struct AchievementGridView: View {
    let unlocked: [Achievement]
    let locked: [AchievementDefinition]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ACHIEVEMENTS")
                .font(.caption)
                .fontWeight(.heavy)
                .fontDesign(.monospaced)
                .foregroundColor(.gray)

            if unlocked.isEmpty && locked.isEmpty {
                Text("No achievements yet. Begin your journey, Hunter.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(unlocked, id: \.id) { achievement in
                        unlockedCard(achievement)
                    }
                    ForEach(locked) { def in
                        lockedCard(def)
                    }
                }
            }
        }
    }

    private func unlockedCard(_ achievement: Achievement) -> some View {
        VStack(spacing: 6) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(.xpGold)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.xpGold.opacity(0.15))
                )

            Text(achievement.name)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(1)

            Text(achievement.detail)
                .font(.caption2)
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.xpGold.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func lockedCard(_ def: AchievementDefinition) -> some View {
        VStack(spacing: 6) {
            Image(systemName: "lock.fill")
                .font(.title2)
                .foregroundColor(.gray.opacity(0.4))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.03))
                )

            Text(def.title)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.gray.opacity(0.5))
                .lineLimit(1)

            Text(def.description)
                .font(.caption2)
                .foregroundColor(.gray.opacity(0.3))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.cardBackground.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }
}
