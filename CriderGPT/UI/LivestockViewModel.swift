import Foundation
class LivestockViewModel: ObservableObject {
    @Published var animals: [LivestockAnimal] = []
    private let service = LivestockService()
    @MainActor func loadAnimals() async {
        do {
            self.animals = try await service.fetchAnimals()
        } catch {
            print("Error loading livestock: \(error)")
        }
    }
}
