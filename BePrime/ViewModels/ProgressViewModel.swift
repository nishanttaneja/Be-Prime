import SwiftUI
import SwiftData

@Observable
final class ProgressViewModel {
    var selectedPeriod: TimePeriod = .weekly
    var completionData: [ChartDataPoint] = []
    var habitBreakdown: [HabitChartData] = []
    var averageRate: Double = 0
    var perfectDaysInPeriod: Int = 0
    var totalXPInPeriod: Int = 0

    struct ChartDataPoint: Identifiable {
        let id = UUID()
        let label: String
        let date: Date
        let value: Double
    }

    struct HabitChartData: Identifiable {
        let id: UUID
        let name: String
        let icon: String
        let completionRate: Double
        let category: HabitCategory
    }

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func onAppear() {
        loadData()
    }

    func loadData() {
        loadCompletionData()
        loadHabitBreakdown()
    }

    private func loadCompletionData() {
        let days = selectedPeriod.dayCount
        let startDate = Date().adding(days: -days)
        let startKey = startDate.toDateKey()

        let descriptor = FetchDescriptor<DailyRecord>(
            predicate: #Predicate { $0.dateKey >= startKey },
            sortBy: [SortDescriptor(\.dateKey)]
        )
        let records = (try? modelContext.fetch(descriptor)) ?? []
        // Tolerate a duplicate dateKey instead of crashing the Progress tab
        let recordMap = Dictionary(records.map { ($0.dateKey, $0) }, uniquingKeysWith: { first, _ in first })

        var data: [ChartDataPoint] = []
        var totalRate: Double = 0
        var perfectCount = 0
        var totalXP = 0
        var dayCount = 0

        for offset in 0..<days {
            let date = startDate.adding(days: offset + 1)
            let key = date.toDateKey()

            let rate: Double
            if let record = recordMap[key] {
                rate = record.totalHabitsAvailable > 0
                    ? Double(record.completedCount) / Double(record.totalHabitsAvailable) * 100
                    : 0
                if record.allCompleted { perfectCount += 1 }
                totalXP += record.totalXPEarned
            } else {
                rate = 0
            }

            let formatter = DateFormatter()
            formatter.dateFormat = selectedPeriod == .yearly ? "MMM" : "M/d"
            let label = formatter.string(from: date)

            data.append(ChartDataPoint(label: label, date: date, value: rate))
            totalRate += rate
            dayCount += 1
        }

        completionData = data
        averageRate = dayCount > 0 ? totalRate / Double(dayCount) : 0
        perfectDaysInPeriod = perfectCount
        totalXPInPeriod = totalXP
    }

    private func loadHabitBreakdown() {
        let days = selectedPeriod.dayCount
        let startDate = Date().adding(days: -days)
        let startKey = startDate.toDateKey()

        // Fetch active habits
        let habitDescriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.isArchived == false },
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        let habits = (try? modelContext.fetch(habitDescriptor)) ?? []

        // Fetch all records in period
        let recordDescriptor = FetchDescriptor<DailyRecord>(
            predicate: #Predicate { $0.dateKey >= startKey }
        )
        let records = (try? modelContext.fetch(recordDescriptor)) ?? []

        // Build completion map per habit
        var breakdown: [HabitChartData] = []
        for habit in habits {
            let completionsInPeriod = habit.completions.filter { completion in
                guard let record = completion.dailyRecord else { return false }
                return record.dateKey >= startKey
            }
            let completedCount = completionsInPeriod.filter(\.isCompleted).count
            let totalDays = max(1, records.count)
            let rate = Double(completedCount) / Double(totalDays)

            breakdown.append(HabitChartData(
                id: habit.id,
                name: habit.name,
                icon: habit.icon,
                completionRate: rate,
                category: habit.category
            ))
        }

        habitBreakdown = breakdown.sorted { $0.completionRate > $1.completionRate }
    }
}
