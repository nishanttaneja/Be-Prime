import Foundation
import SwiftData

@Model
final class Achievement {
    var id: UUID
    var key: String
    var name: String
    var detail: String
    var icon: String
    var unlockedAt: Date

    var profile: HunterProfile?

    init(key: String, name: String, detail: String, icon: String) {
        self.id = UUID()
        self.key = key
        self.name = name
        self.detail = detail
        self.icon = icon
        self.unlockedAt = Date()
    }
}
