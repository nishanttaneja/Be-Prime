import SwiftUI
import SwiftData

struct HunterCardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: HunterCardViewModel?
    @State private var isEditingName = false
    @State private var editedName = ""

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    hunterContent(vm: vm)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Hunter Card")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.appBackground)
        }
        .onAppear {
            if viewModel == nil {
                viewModel = HunterCardViewModel(modelContext: modelContext)
            }
            // Always reload on appear — picks up XP/level changes from quest board
            viewModel?.onAppear()
        }
    }

    private func hunterContent(vm: HunterCardViewModel) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Hunter identity card
                hunterIdentity(vm: vm)

                // Power Level
                PowerLevelView(powerLevel: vm.powerLevel)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .systemWindow()
                    .padding(.horizontal)

                // Stats grid
                statsGrid(vm: vm)

                // Penalty status
                if vm.isInPenaltyZone {
                    penaltyStatus(vm: vm)
                }

                // Achievements
                AchievementGridView(
                    unlocked: vm.unlockedAchievements,
                    locked: vm.lockedAchievements
                )
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
    }

    private func hunterIdentity(vm: HunterCardViewModel) -> some View {
        VStack(spacing: 16) {
            RankBadgeView(rank: vm.rank, size: 80)

            // Hunter name
            if isEditingName {
                HStack {
                    TextField("Hunter Name", text: $editedName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .onSubmit {
                            vm.updateHunterName(editedName)
                            isEditingName = false
                        }

                    Button {
                        vm.updateHunterName(editedName)
                        isEditingName = false
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.xpGreen)
                    }
                }
                .padding(.horizontal, 40)
            } else {
                Button {
                    editedName = vm.profile?.hunterName ?? "Hunter"
                    isEditingName = true
                } label: {
                    HStack(spacing: 6) {
                        Text(vm.profile?.hunterName ?? "Hunter")
                            .font(.title2)
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                            .foregroundStyle(.white)

                        Image(systemName: "pencil")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
            }

            // Rank title
            Text(vm.rank.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(vm.rank.color)

            // Level + XP
            VStack(spacing: 6) {
                Text("Level \(vm.level)")
                    .font(.headline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(.white)

                XPProgressBar(
                    earned: vm.xpProgress.earned,
                    required: vm.xpProgress.required,
                    height: 8
                )
                .padding(.horizontal, 40)

                Text("Total XP: \(vm.totalXP)")
                    .font(.caption)
                    .fontDesign(.monospaced)
                    .foregroundStyle(.xpGold)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .systemWindow()
        .padding(.horizontal)
    }

    private func statsGrid(vm: HunterCardViewModel) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            statCell(title: "Current Streak", value: "\(vm.currentStreak)", icon: "flame.fill", color: .flameOrange)
            statCell(title: "Best Streak", value: "\(vm.longestStreak)", icon: "trophy.fill", color: .xpGold)
            statCell(title: "Perfect Days", value: "\(vm.totalPerfectDays)", icon: "checkmark.seal.fill", color: .xpGreen)
            statCell(title: "Days Tracked", value: "\(vm.totalDaysTracked)", icon: "calendar", color: .systemBlue)
            statCell(title: "Quests Done", value: "\(vm.totalHabitsCompleted)", icon: "scroll.fill", color: .purple)
            statCell(title: "XP Lost", value: "\(vm.totalXPLost)", icon: "arrow.down.circle.fill", color: .penaltyRed)
        }
        .padding(.horizontal)
    }

    private func statCell(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.headline)
                .fontDesign(.monospaced)
                .foregroundStyle(.white)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.gray)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.systemBorder.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func penaltyStatus(vm: HunterCardViewModel) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.penaltyRed)

            VStack(alignment: .leading, spacing: 2) {
                Text("PENALTY ZONE ACTIVE")
                    .font(.caption)
                    .fontWeight(.heavy)
                    .fontDesign(.monospaced)
                    .foregroundStyle(.penaltyRed)

                Text("Complete all daily quests to escape. XP halved.")
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }

            Spacer()
        }
        .padding(12)
        .systemWindow(penaltyZone: true)
        .padding(.horizontal)
    }
}
