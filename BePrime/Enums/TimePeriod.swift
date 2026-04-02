import Foundation

enum TimePeriod: String, CaseIterable, Identifiable, Sendable {
    case weekly = "W"
    case monthly = "M"
    case yearly = "Y"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .weekly: "Week"
        case .monthly: "Month"
        case .yearly: "Year"
        }
    }

    var dayCount: Int {
        switch self {
        case .weekly: 7
        case .monthly: 30
        case .yearly: 365
        }
    }
}
