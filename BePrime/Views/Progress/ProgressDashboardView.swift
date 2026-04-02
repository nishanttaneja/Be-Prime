import SwiftUI
import SwiftData

struct ProgressDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ProgressViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    progressContent(vm: vm)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.appBackground)
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ProgressViewModel(modelContext: modelContext)
            }
            // Always reload data on appear — picks up quest completions from other tabs
            viewModel?.onAppear()
        }
    }

    private func progressContent(vm: ProgressViewModel) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Time period picker
                Picker("Period", selection: Binding(
                    get: { vm.selectedPeriod },
                    set: {
                        vm.selectedPeriod = $0
                        vm.loadData()
                    }
                )) {
                    ForEach(TimePeriod.allCases) { period in
                        Text(period.displayName).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Summary stats
                summaryRow(vm: vm)

                // Completion chart
                CompletionRateChartView(data: vm.completionData, period: vm.selectedPeriod)
                    .padding(16)
                    .systemWindow()
                    .padding(.horizontal)

                // Habit breakdown
                HabitBreakdownChartView(data: vm.habitBreakdown)
                    .padding(16)
                    .systemWindow()
                    .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
    }

    private func summaryRow(vm: ProgressViewModel) -> some View {
        HStack(spacing: 0) {
            summaryCell(title: "Avg Rate", value: "\(Int(vm.averageRate))%", color: .systemBlue)
            Divider().frame(height: 40).overlay(Color.systemBorder.opacity(0.3))
            summaryCell(title: "Perfect Days", value: "\(vm.perfectDaysInPeriod)", color: .xpGreen)
            Divider().frame(height: 40).overlay(Color.systemBorder.opacity(0.3))
            summaryCell(title: "XP Earned", value: "\(vm.totalXPInPeriod)", color: .xpGold)
        }
        .padding(.vertical, 12)
        .systemWindow()
        .padding(.horizontal)
    }

    private func summaryCell(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontDesign(.monospaced)
                .foregroundStyle(color)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}
