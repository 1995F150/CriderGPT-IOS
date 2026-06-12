import Foundation
struct LivestockAnimal: Identifiable, Codable {
    let id: UUID
    let tag_id: String
    let species: String
    let name: String?
    let birth_date: Date?
    let status: String
    let created_at: Date
}
