import SwiftUI
import SwiftData

struct QuestBoardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel: QuestBoardViewModel?
    @State private var showHabitManagement = false

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    questContent(vm: vm)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Daily Dungeon")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showHabitManagement = true
                    } label: {
                        Image(systemName: "list.bullet.rectangle")
                            .foregroundColor(.systemBlue)
                    }
                }
            }
            .sheet(isPresented: $showHabitManagement) {
                HabitListView()
                    .onDisappear {
                        viewModel?.onAppear()
                    }
            }
            .background(Color.appBackground)
        }
        .onAppear {
            if viewModel == nil {
                viewModel = QuestBoardViewModel(modelContext: modelContext)
            }
            viewModel?.onAppear()
        }
        // Re-run the daily reset when the app comes back to the foreground: onAppear alone
        // misses an app that was left open across midnight
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { viewModel?.onAppear() }
        }
        .overlay {
            if let vm = viewModel {
                levelOverlay(vm: vm)
            }
        }
    }

    @ViewBuilder
    private func questContent(vm: QuestBoardViewModel) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                // System message
                SystemMessageView(message: vm.systemMessage)
                    .padding(.horizontal)

                // Penalty Zone banner
                if vm.isInPenaltyZone {
                    PenaltyZoneBannerView()
                }

                // Header: progress ring + stats
                headerSection(vm: vm)

                // Quest cards
                if vm.questItems.isEmpty {
                    ContentUnavailableView {
                        Label("No Quests", systemImage: "scroll")
                    } description: {
                        Text("Add daily quests to enter the dungeon.")
                    }
                    .padding(.top, 40)
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(vm.questItems) { item in
                            QuestCardView(
                                item: item,
                                isInPenaltyZone: vm.isInPenaltyZone
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    vm.toggleQuest(item)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 20)
        }
    }

    private func headerSection(vm: QuestBoardViewModel) -> some View {
        HStack(spacing: 20) {
            DailyProgressRingView(
                completed: vm.questItems.filter(\.isCompleted).count,
                total: vm.questItems.count
            )

            VStack(alignment: .leading, spacing: 8) {
                // Rank & Level
                HStack(spacing: 6) {
                    Text(vm.currentRank.shortTitle)
                        .font(.caption)
                        .fontWeight(.heavy)
                        .fontDesign(.monospaced)
                        .foregroundColor(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule().fill(vm.currentRank.color)
                        )

                    Text("Lv. \(vm.currentLevel)")
                        .font(.headline)
                        .fontDesign(.monospaced)
                        .foregroundColor(.white)
                }

                // XP bar
                XPProgressBar(
                    earned: vm.xpProgress.earned,
                    required: vm.xpProgress.required,
                    height: 6
                )

                // Streak + daily XP
                HStack(spacing: 12) {
                    StreakFlameView(streak: vm.currentStreak)

                    Spacer()

                    Text("+\(vm.dailyXPEarned) XP")
                        .font(.caption)
                        .fontDesign(.monospaced)
                        .foregroundColor(.xpGold)
                }
            }
        }
        .padding(16)
        .systemWindow(penaltyZone: vm.isInPenaltyZone)
        .padding(.horizontal)
    }

    @ViewBuilder
    private func levelOverlay(vm: QuestBoardViewModel) -> some View {
        if vm.showLevelUpOverlay {
            LevelUpOverlayView(
                level: vm.newLevel,
                rank: vm.newRank,
                isLevelDown: false
            ) {
                vm.showLevelUpOverlay = false
            }
            .transition(.opacity)
        }

        if vm.showLevelDownOverlay {
            LevelUpOverlayView(
                level: vm.newLevel,
                rank: nil,
                isLevelDown: true
            ) {
                vm.showLevelDownOverlay = false
            }
            .transition(.opacity)
        }
    }
}
