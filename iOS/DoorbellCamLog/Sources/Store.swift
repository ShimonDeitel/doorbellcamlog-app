import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var items: [DoorbellCamLogItem] = []
    @Published var isPro: Bool = false

    /// Free tier limit is intentionally well above seed data count so a fresh
    /// install never trips the paywall immediately.
    static let freeLimit = 15

    private let fileURL: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        fileURL = support.appendingPathComponent("doorbellcamlog_items.json")
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([DoorbellCamLogItem].self, from: data) else {
            items = [
        DoorbellCamLogItem(title: "Package left", description: "UPS dropped off a box on the mat", category: "Delivery"),
        DoorbellCamLogItem(title: "Unknown visitor", description: "Someone rang twice, no ID", category: "Visitor"),
        DoorbellCamLogItem(title: "Dog walker", description: "Neighbor's dog walker passed by", category: "Neighbor")
            ]
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    @discardableResult
    func add(_ item: DoorbellCamLogItem) -> Bool {
        guard canAddMore else { return false }
        items.insert(item, at: 0)
        save()
        return true
    }

    func update(_ item: DoorbellCamLogItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: DoorbellCamLogItem) {
        items.removeAll(where: { $0.id == item.id })
        save()
    }
}
