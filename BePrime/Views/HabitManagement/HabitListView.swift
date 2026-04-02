import SwiftUI
import SwiftData

struct HabitListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: HabitManagementViewModel?
    @State private var showAddSheet = false
    @State private var editingHabit: Habit?

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    if vm.habits.isEmpty {
                        emptyState
                    } else {
                        habitList(vm: vm)
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Manage Quests")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.systemBlue)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                if let vm = viewModel {
                    HabitFormView(viewModel: vm, habit: nil)
                }
            }
            .sheet(item: $editingHabit) { habit in
                if let vm = viewModel {
                    HabitFormView(viewModel: vm, habit: habit)
                }
            }
            .background(Color.appBackground)
        }
        .onAppear {
            if viewModel == nil {
                viewModel = HabitManagementViewModel(modelContext: modelContext)
            }
            viewModel?.loadHabits()
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Quests", systemImage: "scroll")
        } description: {
            Text("Add daily quests to begin your journey, Hunter.")
        } actions: {
            Button("Add Quest") {
                showAddSheet = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.systemBlue)
        }
    }

    private func habitList(vm: HabitManagementViewModel) -> some View {
        List {
            ForEach(vm.habits, id: \.id) { habit in
                HStack(spacing: 12) {
                    Image(systemName: habit.icon)
                        .font(.title2)
                        .foregroundStyle(habit.category.color)
                        .frame(width: 36)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(habit.name)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("\(habit.xpReward) XP \u{2022} \(habit.category.displayName)")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                .listRowBackground(Color.cardBackground)
                .contentShape(Rectangle())
                .onTapGesture {
                    editingHabit = habit
                }
            }
            .onMove { source, destination in
                vm.moveHabits(from: source, to: destination)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    vm.archiveHabit(vm.habits[index])
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}
