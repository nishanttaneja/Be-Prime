import Foundation

extension Date {
    func toDateKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter.string(from: self)
    }

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    func daysBetween(_ other: Date) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: self)
        let end = calendar.startOfDay(for: other)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    static func fromDateKey(_ key: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter.date(from: key)
    }
}
