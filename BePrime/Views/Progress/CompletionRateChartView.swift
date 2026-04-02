import SwiftUI
import Charts

struct CompletionRateChartView: View {
    let data: [ProgressViewModel.ChartDataPoint]
    let period: TimePeriod

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("COMPLETION RATE")
                .font(.caption)
                .fontWeight(.heavy)
                .fontDesign(.monospaced)
                .foregroundColor(.gray)

            if data.isEmpty {
                Text("No data yet. Complete quests to see progress.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
            } else {
                Chart(data) { point in
                    BarMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Rate", point.value)
                    )
                    .foregroundStyle(barColor(for: point.value))
                    .cornerRadius(2)
                }
                .chartYScale(domain: 0...100)
                .chartYAxis {
                    AxisMarks(values: [0, 25, 50, 75, 100]) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                            .foregroundStyle(Color.white.opacity(0.1))
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                Text("\(Int(v))%")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: xAxisStride, count: xAxisCount)) { _ in
                        AxisValueLabel(format: xAxisFormat)
                            .foregroundStyle(.gray)
                    }
                }
                .frame(height: 200)
            }
        }
    }

    private func barColor(for value: Double) -> Color {
        switch value {
        case 100: .xpGreen
        case 50..<100: .systemBlue
        case 1..<50: .xpGold
        default: .penaltyRed.opacity(0.5)
        }
    }

    private var xAxisStride: Calendar.Component {
        switch period {
        case .weekly: .day
        case .monthly: .weekOfYear
        case .yearly: .month
        }
    }

    private var xAxisCount: Int {
        switch period {
        case .weekly: 1
        case .monthly: 1
        case .yearly: 1
        }
    }

    private var xAxisFormat: Date.FormatStyle {
        switch period {
        case .weekly: .dateTime.weekday(.abbreviated)
        case .monthly: .dateTime.day()
        case .yearly: .dateTime.month(.abbreviated)
        }
    }
}
