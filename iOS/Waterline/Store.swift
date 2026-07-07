import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [LevelEntry] = []
    @Published var isProUnlocked: Bool = false

    /// Free tier keeps every seeded entry visible without hitting the paywall on first launch.
    static let freeTierLimit = 20

    private let fileURL: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = appSupport.appendingPathComponent("Waterline", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("entries.json")
        load()
    }

    var canAddMore: Bool {
        isProUnlocked || entries.count < Store.freeTierLimit
    }

    func add(_ entry: LevelEntry) {
        guard canAddMore else { return }
        entries.insert(entry, at: 0)
        save()
    }

    func update(_ entry: LevelEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: LevelEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([LevelEntry].self, from: data) {
            entries = decoded
        } else {
            entries = Store.seedData()
            save()
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func seedData() -> [LevelEntry] {
        [
        LevelEntry(spotName: "Water Level 1", level: "Water Level 1", notes: "Water Level 1"),
        LevelEntry(spotName: "Water Level 2", level: "Water Level 2", notes: "Water Level 2"),
        LevelEntry(spotName: "Water Level 3", level: "Water Level 3", notes: "Water Level 3"),
        LevelEntry(spotName: "Water Level 4", level: "Water Level 4", notes: "Water Level 4")
        ]
    }
}
