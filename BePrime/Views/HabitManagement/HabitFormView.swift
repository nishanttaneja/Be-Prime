import SwiftUI

struct HabitFormView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: HabitManagementViewModel
    let habit: Habit?

    @State private var name: String = ""
    @State private var selectedIcon: String = "star.fill"
    @State private var selectedCategory: HabitCategory = .general
    @State private var xpReward: Int = 50

    private let iconOptions = [
        "star.fill", "drop.fill", "fork.knife", "figure.run",
        "bed.double.fill", "brain.head.profile", "book.fill",
        "dumbbell.fill", "heart.fill", "leaf.fill",
        "sun.max.fill", "moon.fill", "clock.fill",
        "pencil.and.outline", "music.note", "globe.americas.fill"
    ]

    var isEditing: Bool { habit != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Quest Details") {
                    TextField("Quest Name", text: $name)
                        .foregroundStyle(.white)

                    Stepper("XP Reward: \(xpReward)", value: $xpReward, in: 25...200, step: 25)
                        .foregroundStyle(.white)
                }
                .listRowBackground(Color.cardBackground)

                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(HabitCategory.allCases) { category in
                            Label(category.displayName, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .foregroundStyle(.white)
                }
                .listRowBackground(Color.cardBackground)

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        selectedIcon == icon ?
                                        Color.systemBlue.opacity(0.3) :
                                        Color.clear
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedIcon == icon ? Color.systemBlue : Color.clear, lineWidth: 2)
                                    )
                            }
                            .tint(.white)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color.cardBackground)
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle(isEditing ? "Edit Quest" : "New Quest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        save()
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .tint(.systemBlue)
                }
            }
        }
        .onAppear {
            if let habit {
                name = habit.name
                selectedIcon = habit.icon
                selectedCategory = habit.category
                xpReward = habit.xpReward
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        if let habit {
            viewModel.updateHabit(habit, name: trimmedName, icon: selectedIcon, category: selectedCategory, xpReward: xpReward)
        } else {
            viewModel.addHabit(name: trimmedName, icon: selectedIcon, category: selectedCategory, xpReward: xpReward)
        }
    }
}
