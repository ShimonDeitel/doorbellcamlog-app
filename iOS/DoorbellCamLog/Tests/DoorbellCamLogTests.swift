import XCTest
@testable import DoorbellCamLog

@MainActor
final class StoreTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
        store.items = []
        store.isPro = false
    }

    func testAddItem() {
        let item = DoorbellCamLogItem(title: "A", description: "B", category: "C")
        let added = store.add(item)
        XCTAssertTrue(added)
        XCTAssertEqual(store.items.count, 1)
    }

    func testFreeLimitBlocksAdd() {
        for i in 0..<Store.freeLimit {
            store.add(DoorbellCamLogItem(title: "\(i)", description: "B", category: "C"))
        }
        XCTAssertEqual(store.items.count, Store.freeLimit)
        let blocked = store.add(DoorbellCamLogItem(title: "over", description: "B", category: "C"))
        XCTAssertFalse(blocked)
        XCTAssertEqual(store.items.count, Store.freeLimit)
    }

    func testProBypassesLimit() {
        store.isPro = true
        for i in 0..<(Store.freeLimit + 5) {
            store.add(DoorbellCamLogItem(title: "\(i)", description: "B", category: "C"))
        }
        XCTAssertEqual(store.items.count, Store.freeLimit + 5)
    }

    func testDeleteItem() {
        let item = DoorbellCamLogItem(title: "A", description: "B", category: "C")
        store.add(item)
        store.delete(item)
        XCTAssertTrue(store.items.isEmpty)
    }

    func testUpdateItem() {
        var item = DoorbellCamLogItem(title: "A", description: "B", category: "C")
        store.add(item)
        item.title = "Updated"
        store.update(item)
        XCTAssertEqual(store.items.first?.title, "Updated")
    }

    func testCanAddMoreTrueInitially() {
        XCTAssertTrue(store.canAddMore)
    }

    func testDeleteAtOffsets() {
        store.add(DoorbellCamLogItem(title: "A", description: "B", category: "C"))
        store.add(DoorbellCamLogItem(title: "D", description: "E", category: "F"))
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.items.count, 1)
    }

    func testPersistenceRoundTrip() {
        store.add(DoorbellCamLogItem(title: "Persist", description: "B", category: "C"))
        let reloaded = Store()
        XCTAssertTrue(reloaded.items.contains(where: { $0.title == "Persist" }))
    }
}
