import Foundation

struct AppSession: Codable, Equatable {
    var accessToken: String
    var refreshToken: String
    var userID: String
    var email: String?
    var expiresAt: Date?
}

struct UserProfile: Codable, Equatable {
    var id: String
    var fullName: String?
    var email: String?
    var avatarURL: String?
    var phoneNumber: String?
    var smsEnabled: Bool?
    var role: String?
}

enum SubscriptionPlan: String, Codable, CaseIterable, Hashable {
    case free = "Free"
    case plus = "Plus"
    case pro = "Pro"
}

enum PlanDisplayState: Equatable {
    case current
    case upgrade
    case includedInPro
    case unavailable

    var label: String {
        switch self {
        case .current:
            return "Current Plan"
        case .upgrade:
            return "Upgrade"
        case .includedInPro:
            return "Included With Pro"
        case .unavailable:
            return "Unavailable"
        }
    }
}

struct SubscriptionState: Codable, Equatable {
    var activePlan: SubscriptionPlan = .free
    var plusActive: Bool = false
    var proActive: Bool = false
    var source: String = "local"
    var verifiedAt: Date?

    static var free: SubscriptionState {
        SubscriptionState()
    }

    var currentPlan: SubscriptionPlan {
        if proActive || activePlan == .pro {
            return .pro
        }
        if plusActive || activePlan == .plus {
            return .plus
        }
        return .free
    }

    func displayState(for plan: SubscriptionPlan) -> PlanDisplayState {
        switch (currentPlan, plan) {
        case (.pro, .pro):
            return .current
        case (.pro, .plus):
            return .includedInPro
        case (.plus, .plus):
            return .current
        case (.plus, .pro):
            return .upgrade
        case (.free, .free):
            return .current
        case (.free, .plus), (.free, .pro):
            return .upgrade
        }
    }
}

struct FeatureSpec: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let section: String
    let route: AppRoute
    let requiresBackend: Bool
}

struct ActionButtonSpec: Hashable {
    let title: String
    let systemImage: String
    let route: AppRoute?
}
