import SwiftUI
import SwiftData

@Observable
final class SettingsViewModel {
    var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
            if notificationsEnabled {
                Task {
                    let granted = await NotificationService.requestPermission()
                    if granted {
                        NotificationService.scheduleDailyReminder(at: reminderTime)
                    } else {
                        await MainActor.run {
                            notificationsEnabled = false
                        }
                    }
                }
            } else {
                NotificationService.cancelDailyReminder()
            }
        }
    }

    var reminderTime: Date {
        didSet {
            UserDefaults.standard.set(reminderTime.timeIntervalSince1970, forKey: "reminderTime")
            if notificationsEnabled {
                NotificationService.scheduleDailyReminder(at: reminderTime)
            }
        }
    }

    var hapticFeedbackEnabled: Bool {
        didSet {
            UserDefaults.standard.set(hapticFeedbackEnabled, forKey: "hapticFeedbackEnabled")
        }
    }

    init() {
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        self.hapticFeedbackEnabled = UserDefaults.standard.object(forKey: "hapticFeedbackEnabled") as? Bool ?? true

        let savedTime = UserDefaults.standard.double(forKey: "reminderTime")
        if savedTime > 0 {
            self.reminderTime = Date(timeIntervalSince1970: savedTime)
        } else {
            // Default: 8 PM
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = 20
            components.minute = 0
            self.reminderTime = Calendar.current.date(from: components) ?? Date()
        }
    }

    func resetAllData(modelContext: ModelContext) {
        // Delete all records
        try? modelContext.delete(model: HabitCompletion.self)
        try? modelContext.delete(model: DailyRecord.self)
        try? modelContext.delete(model: Achievement.self)
        try? modelContext.delete(model: HunterProfile.self)
        try? modelContext.delete(model: Habit.self)

        // Re-seed defaults
        DefaultHabitsProvider.seedDefaultHabits(modelContext: modelContext)
        _ = DefaultHabitsProvider.ensureProfileExists(modelContext: modelContext)
    }
}
