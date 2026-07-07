import Foundation

struct LevelEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var createdAt: Date
    var spotName: String
    var level: String
    var notes: String

    init(id: UUID = UUID(), createdAt: Date = Date(), spotName: String = "", level: String = "", notes: String = "") {
        self.id = id
        self.createdAt = createdAt
        self.spotName = spotName
        self.level = level
        self.notes = notes
    }
}
