import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SettingsViewModel()
    @State private var showResetConfirmation = false
    @State private var showHabitManagement = false

    var body: some View {
        NavigationStack {
            Form {
                // Notifications section
                Section {
                    Toggle("Daily Reminder", isOn: Binding(
                        get: { viewModel.notificationsEnabled },
                        set: { viewModel.notificationsEnabled = $0 }
                    ))

                    if viewModel.notificationsEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: Binding(
                                get: { viewModel.reminderTime },
                                set: { viewModel.reminderTime = $0 }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Receive a System notification to remind you about incomplete quests.")
                }
                .listRowBackground(Color.cardBackground)

                // General section
                Section("General") {
                    Toggle("Haptic Feedback", isOn: Binding(
                        get: { viewModel.hapticFeedbackEnabled },
                        set: { viewModel.hapticFeedbackEnabled = $0 }
                    ))
                }
                .listRowBackground(Color.cardBackground)

                // Quest management
                Section("Quests") {
                    Button {
                        showHabitManagement = true
                    } label: {
                        HStack {
                            Label("Manage Quests", systemImage: "list.bullet.rectangle")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .tint(.white)
                }
                .listRowBackground(Color.cardBackground)

                // Danger zone
                Section {
                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        Label("Reset All Data", systemImage: "trash")
                    }
                } header: {
                    Text("Danger Zone")
                } footer: {
                    Text("This will permanently delete all progress, habits, and achievements. This action cannot be undone.")
                }
                .listRowBackground(Color.cardBackground)

                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Be Prime")
                        Spacer()
                        Text("Achieve Your Prime Self")
                            .font(.caption)
                            .foregroundColor(.systemBlue)
                    }
                }
                .listRowBackground(Color.cardBackground)
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showHabitManagement) {
                HabitListView()
            }
            .alert("Reset All Data?", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset Everything", role: .destructive) {
                    viewModel.resetAllData(modelContext: modelContext)
                }
            } message: {
                Text("[System] WARNING: All hunter data will be permanently erased. Your rank, level, XP, streaks, and achievements will be lost forever. This cannot be undone.")
            }
        }
    }
}
