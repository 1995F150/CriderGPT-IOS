import Foundation
import Supabase
import UIKit

struct Receipt: Codable, Identifiable {
    var id: Int?
    var merchant: String
    var amount: Double
    var date: Date
    var image_url: String?
    var created_at: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, merchant, amount, date, image_url, created_at
    }
}

class ReceiptsService: ObservableObject {
    static let shared = ReceiptsService()
    private let client: SupabaseClient
    
    @Published var receipts: [Receipt] = []
    @Published var isLoading = false
    
    init(client: SupabaseClient = SupabaseService.shared.client) {
        self.client = client
    }
    
    func fetchReceipts() async {
        DispatchQueue.main.async { self.isLoading = true }
        defer { DispatchQueue.main.async { self.isLoading = false } }
        
        do {
            let receipts: [Receipt] = try await client.database
                .from("receipts")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            
            DispatchQueue.main.async {
                self.receipts = receipts
            }
        } catch {
            print("### Error fetching receipts: \(error)")
        }
    }
    
    func uploadReceipt(image: UIImage, merchant: String, amount: Double, date: Date) async throws {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageConversion", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }
        
        let fileName = "\(UUID().uuidString).jpg"
        let filePath = "receipts/\(fileName)"
        
        // 1. Upload to Supabase Storage
        _ = try await client.storage
            .from("receipts")
            .upload(path: filePath, file: data, options: FileOptions(contentType: "image/jpeg"))
        
        // 2. Get Public URL
        let publicURL = try client.storage
            .from("receipts")
            .getPublicUrl(path: filePath)
        
        // 3. Insert into Database
        let receipt = Receipt(
            merchant: merchant,
            amount: amount,
            date: date,
            image_url: publicURL.absoluteString
        )
        
        try await client.database
            .from("receipts")
            .insert(receipt)
            .execute()
        
        await fetchReceipts()
    }
}
