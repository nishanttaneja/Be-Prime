import SwiftUI

struct QuestCardView: View {
    let item: QuestBoardViewModel.QuestItem
    let isInPenaltyZone: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                // Icon
                Image(systemName: item.habitIcon)
                    .font(.title2)
                    .foregroundColor(item.isCompleted ? .gray : item.category.color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(item.isCompleted ? Color.white.opacity(0.05) : item.category.color.opacity(0.15))
                    )

                // Quest details
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.habitName)
                        .font(.headline)
                        .foregroundColor(item.isCompleted ? .gray : .white)
                        .strikethrough(item.isCompleted, color: .gray)

                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                        Text(isInPenaltyZone ? "\(item.xpReward / 2) XP (0.5\u{00d7})" : "\(item.xpReward) XP")
                            .font(.caption)
                            .fontDesign(.monospaced)
                    }
                    .foregroundColor(item.isCompleted ? .gray : .xpGold)
                }

                Spacer()

                // Completion indicator
                ZStack {
                    Circle()
                        .stroke(item.isCompleted ? Color.xpGreen : Color.systemBorder, lineWidth: 2)
                        .frame(width: 28, height: 28)

                    if item.isCompleted {
                        Circle()
                            .fill(Color.xpGreen)
                            .frame(width: 28, height: 28)

                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                }
            }
            .padding(14)
            .systemWindow(penaltyZone: isInPenaltyZone)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(item.isCompleted ? .impact(flexibility: .soft) : .success, trigger: item.isCompleted)
    }
}
