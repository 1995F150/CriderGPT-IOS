import Foundation
import Supabase

class ReceiptsService: ObservableObject {
    static let shared = ReceiptsService()
    private let client: SupabaseClient
    
    @Published var receipts: [Receipt] = []
    @Published var isLoading = false
    
    init(client: SupabaseClient = SupabaseService.shared.client) {
        self.client = client
    }
    
    func uploadReceiptImage(data: Data, fileName: String) async throws -> String {
        let storage = client.storage.from("receipts")
        _ = try await storage.upload(
            path: fileName,
            file: data,
            options: FileOptions(cacheControl: "3600", upsert: true)
        )
        
        let url = try storage.getPublicUrl(path: fileName)
        return url.absoluteString
    }
    
    func saveReceiptMetadata(title: String, amount: Double, date: Date, imageURL: String) async throws {
        let receipt = Receipt(
            title: title,
            amount: amount,
            date: date,
            imageURL: imageURL,
            userId: client.auth.session?.user.id
        )
        
        try await client.database
            .from("receipts")
            .insert(receipt)
            .execute()
    }
    
    func fetchReceipts() async throws {
        isLoading = true
        defer { isLoading = false }
        
        let response: [Receipt] = try await client.database
            .from("receipts")
            .select()
            .order("date", ascending: false)
            .execute()
            .value
        
        await MainActor.run {
            self.receipts = response
        }
    }
}

struct Receipt: Codable, Identifiable {
    var id: UUID?
    let title: String
    let amount: Double
    let date: Date
    let imageURL: String
    let userId: UUID?
    
    enum CodingKeys: String, CodingKey {
        case id, title, amount, date, userId = "user_id", imageURL = "image_url"
    }
}
