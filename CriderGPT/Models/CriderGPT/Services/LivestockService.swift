import Foundation
import Supabase
class LivestockService {
    private let supabase = SupabaseService.shared.client
    func fetchAnimals() async throws -> [LivestockAnimal] {
        return try await supabase.from("livestock_animals").select("*").execute().value
    }
}
