import XCTest
@testable import Waterline

@MainActor
final class WaterlineTests: XCTestCase {
    var store: Store!

    override func setUp() async throws {
        store = Store()
    }

    func testSeedDataLoadsBelowFreeLimit() {
        XCTAssertLessThan(store.entries.count, Store.freeTierLimit)
    }

    func testAddEntryIncreasesCount() {
        let before = store.entries.count
        store.add(LevelEntry(spotName: "Test Entry"))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testAddedEntryAppearsFirst() {
        store.add(LevelEntry(spotName: "Newest"))
        XCTAssertEqual(store.entries.first?.spotName, "Newest")
    }

    func testDeleteRemovesEntry() {
        let entry = LevelEntry(spotName: "ToDelete")
        store.add(entry)
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(entry))
    }

    func testCanAddMoreWhenBelowLimit() {
        XCTAssertTrue(store.canAddMore)
    }

    func testCannotAddMoreAtFreeLimitWithoutPro() {
        store.entries = (0..<Store.freeTierLimit).map { _ in LevelEntry(spotName: "X") }
        XCTAssertFalse(store.canAddMore)
    }

    func testAddBlockedAtLimitDoesNotAppend() {
        store.entries = (0..<Store.freeTierLimit).map { _ in LevelEntry(spotName: "X") }
        let before = store.entries.count
        store.add(LevelEntry(spotName: "Overflow"))
        XCTAssertEqual(store.entries.count, before)
    }

    func testUpdateModifiesExistingEntry() {
        let entry = LevelEntry(spotName: "Original")
        store.add(entry)
        var updated = entry
        updated.spotName = "Updated"
        store.update(updated)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.spotName, "Updated")
    }
}
