import Foundation
import SwiftUI
import AuthenticationServices

@MainActor
final class AppModel: ObservableObject {
    @Published var session: AppSession?
    @Published var profile: UserProfile?
    @Published var subscriptionState: SubscriptionState = .free
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var path: [AppRoute] = []
    @Published var selectedRoute: AppRoute = .dashboard
    @Published var isAuthenticated = false

    private let keychain = KeychainStore()
    private let backend = SupabaseService()
    private let sessionAccount = "current-session"

    func boot() async {
        isLoading = true
        defer { isLoading = false }

        do {
            if let restored = try await restoreSessionFromKeychain() {
                session = restored
                try await hydrateAccount(using: restored)
                isAuthenticated = true
                selectedRoute = .dashboard
                return
            }
            session = nil
            profile = nil
            subscriptionState = .free
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
            session = nil
            profile = nil
            subscriptionState = .free
            isAuthenticated = false
        }
    }

    func signIn(email: String, password: String) async {
        await performAuth { [backend] in
            try await backend.signInWithEmail(email: email, password: password)
        }
    }

    func signInWithGoogle(anchorProvider: ASWebAuthenticationPresentationContextProviding) async {
        await performAuth { [backend] in
            try await backend.signInWithGoogle(presentationContextProvider: anchorProvider)
        }
    }

    func logout() async {
        guard let session else {
            resetToSignedOutState()
            return
        }
        await backend.signOut(accessToken: session.accessToken)
        keychain.delete(account: sessionAccount)
        resetToSignedOutState()
    }

    func refreshAccountState() async {
        guard let session else { return }
        do {
            try await hydrateAccount(using: session)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func go(_ route: AppRoute) {
        selectedRoute = route
        if route == .dashboard {
            path.removeAll()
        } else {
            path = [route]
        }
    }

    func planDisplayState(for plan: SubscriptionPlan) -> PlanDisplayState {
        subscriptionState.displayState(for: plan)
    }

    func openCurrentPlan() {
        switch subscriptionState.currentPlan {
        case .free:
            go(.plan)
        case .plus:
            go(.payment)
        case .pro:
            go(.payment)
        }
    }

    private func performAuth(_ action: @escaping () async throws -> AppSession) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let session = try await action()
            try saveSession(session)
            try await hydrateAccount(using: session)
            self.session = session
            self.isAuthenticated = true
            self.selectedRoute = .dashboard
            self.errorMessage = nil
            self.path.removeAll()
        } catch {
            self.errorMessage = error.localizedDescription
            self.session = nil
            self.profile = nil
            self.subscriptionState = .free
            self.isAuthenticated = false
        }
    }

    private func hydrateAccount(using session: AppSession) async throws {
        let restored = try await backend.restoreSession(session)
        let profile = try await backend.ensureProfile(for: restored, name: session.email)
        let subscriptionState = try await backend.fetchSubscriptionState(userID: restored.userID, accessToken: restored.accessToken)
        self.session = restored
        self.profile = profile
        self.subscriptionState = subscriptionState
        try saveSession(restored)
    }

    private func restoreSessionFromKeychain() async throws -> AppSession? {
        guard let data = try keychain.read(account: sessionAccount) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let session = try decoder.decode(AppSession.self, from: data)
        return try await backend.restoreSession(session)
    }

    private func saveSession(_ session: AppSession) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(session)
        try keychain.save(data, account: sessionAccount)
    }

    private func resetToSignedOutState() {
        session = nil
        profile = nil
        subscriptionState = .free
        isAuthenticated = false
        selectedRoute = .dashboard
        path.removeAll()
    }
}
