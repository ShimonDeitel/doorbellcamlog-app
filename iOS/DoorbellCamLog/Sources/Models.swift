import Foundation

struct DoorbellCamLogItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var description: String
    var category: String
    var createdAt: Date = Date()
}
