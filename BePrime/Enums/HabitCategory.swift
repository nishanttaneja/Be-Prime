import SwiftUI

enum HabitCategory: String, CaseIterable, Identifiable, Sendable {
    case fitness
    case nutrition
    case mind
    case discipline
    case general

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var icon: String {
        switch self {
        case .fitness: "figure.run"
        case .nutrition: "fork.knife"
        case .mind: "brain.head.profile"
        case .discipline: "clock.badge.checkmark"
        case .general: "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .fitness: .orange
        case .nutrition: .green
        case .mind: .purple
        case .discipline: .blue
        case .general: .cyan
        }
    }
}
