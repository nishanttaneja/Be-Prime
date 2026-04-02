import SwiftUI
import Charts

struct HabitBreakdownChartView: View {
    let data: [ProgressViewModel.HabitChartData]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("QUEST BREAKDOWN")
                .font(.caption)
                .fontWeight(.heavy)
                .fontDesign(.monospaced)
                .foregroundStyle(.gray)

            if data.isEmpty {
                Text("No quest data available.")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.vertical, 12)
            } else {
                VStack(spacing: 10) {
                    ForEach(data) { habit in
                        HStack(spacing: 10) {
                            Image(systemName: habit.icon)
                                .font(.caption)
                                .foregroundStyle(habit.category.color)
                                .frame(width: 20)

                            Text(habit.name)
                                .font(.caption)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .frame(width: 100, alignment: .leading)

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.white.opacity(0.1))
                                        .frame(height: 12)

                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(rateColor(habit.completionRate))
                                        .frame(width: geo.size.width * habit.completionRate, height: 12)
                                }
                            }
                            .frame(height: 12)

                            Text("\(Int(habit.completionRate * 100))%")
                                .font(.caption2)
                                .fontDesign(.monospaced)
                                .foregroundStyle(rateColor(habit.completionRate))
                                .frame(width: 36, alignment: .trailing)
                        }
                    }
                }
            }
        }
    }

    private func rateColor(_ rate: Double) -> Color {
        switch rate {
        case 0.8...1.0: .xpGreen
        case 0.5..<0.8: .xpGold
        default: .penaltyRed
        }
    }
}
