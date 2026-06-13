            case .systemDiagnostics:
                GenericBackendView(route: .systemDiagnostics)
            case .farmBureau:
                GenericBackendView(route: .farmBureau)
            case .serverAIConsole:
                GenericBackendView(route: .serverAIConsole)
            case .selfRepair:
                GenericBackendView(route: .selfRepair)
            case .knowledgeVault:import SwiftUI

struct RouteDestinationView: View {
    let route: AppRoute
    
    @ViewBuilder
    var body: some View {
        switch route {
        case .dashboard:
            DashboardView()
        case .chat:
            ChatScreenView()
        case .visionMemory:
            VisionMemoryView()
        case .livestockID:
            LivestockView()
        case .receipts:
            ReceiptsView()
        case .knowledgeVault:
            KnowledgeVaultView()
        case .businessCalculator:
            BusinessCalculatorView()
        case .blueprintGenerator:
            BlueprintGeneratorView()
        case .profile:
            ProfileView()
        case .plan:
            PlanView()
        case .payment:
            PaymentView()
        case .login:
            LoginView()
        default:
            GenericBackendView(route: route)
        }
    }
}
                GenericBackendView(route: .knowledgeVault)
            case .agiDispatcher:
                GenericBackendView(route: .agiDispatcher)
            case .androidBuilder:
                GenericBackendView(route: .androidBuilder)
            case .iosBuilder:
                GenericBackendView(route: .iosBuilder)
            case .swiftGenerator:
                GenericBackendView(route: .swiftGenerator)
            case .businessCalculator:
                GenericBackendView(route: .businessCalculator)
            case .blueprintGenerator:
                GenericBackendView(route: .blueprintGenerator)
