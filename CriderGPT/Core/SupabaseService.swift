import Foundation
import AuthenticationServices

struct SupabaseUser: Decodable {
    let id: String
    let email: String?
}

struct SupabaseAuthResponse: Decodable {
    let access_token: String
    let refresh_token: String
    let expires_in: Int?
    let token_type: String?
    let user: SupabaseUser?
}

struct EdgeFunctionResult: Decodable {
    let success: Bool?
    let message: String?
    let payload: [String: String]?
}

final class SupabaseService {
    enum ServiceError: LocalizedError {
        case missingConfiguration
        case invalidResponse
        case missingSession
        case missingOAuthCallback
        case parsingFailed
        case authorizationFailed(String)
        case backendRequired

        var errorDescription: String? {
            switch self {
            case .missingConfiguration:
                return "Supabase configuration is missing."
            case .invalidResponse:
                return "The backend returned an invalid response."
            case .missingSession:
                return "No session is available."
            case .missingOAuthCallback:
                return "The sign-in callback was not returned."
            case .parsingFailed:
                return "Could not parse backend data."
            case .authorizationFailed(let message):
                return message
            case .backendRequired:
                return "Backend hookup required"
            }
        }
    }

    private let config: AppConfig
    private let urlSession: URLSession

    init(config: AppConfig = AppConfig(), urlSession: URLSession = .shared) {
        self.config = config
        self.urlSession = urlSession
    }

    private var commonHeaders: [String: String] {
        [
            "apikey": config.supabaseAnonKey,
            "Authorization": "Bearer \(config.supabaseAnonKey)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }

    func signInWithEmail(email: String, password: String) async throws -> AppSession {
        let payload = ["email": email, "password": password]
        let request = try makeRequest(path: "token?grant_type=password", method: "POST", authenticated: false, body: payload)
        let (data, response) = try await urlSession.data(for: request)
        try validate(response: response, data: data)
        let auth = try decode(SupabaseAuthResponse.self, from: data)
        guard let user = auth.user else {
            throw ServiceError.missingSession
        }
        return AppSession(
            accessToken: auth.access_token,
            refreshToken: auth.refresh_token,
            userID: user.id,
            email: user.email,
            expiresAt: auth.expires_in.flatMap { Date().addingTimeInterval(TimeInterval($0)) }
        )
    }

    func signInWithGoogle(presentationContextProvider: ASWebAuthenticationPresentationContextProviding) async throws -> AppSession {
        let callbackScheme = config.appleBundleIdentifier
        let authorizeURL = config.authBaseURL.appendingPathComponent("authorize")
        var components = URLComponents(url: authorizeURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "provider", value: "google"),
            URLQueryItem(name: "redirect_to", value: "\(callbackScheme)://auth-callback")
        ]
        guard let url = components?.url else {
            throw ServiceError.invalidResponse
        }

        let callback = try await authenticate(url: url, callbackScheme: callbackScheme, presentationContextProvider: presentationContextProvider)
        guard let fragment = callback.fragment ?? callback.query else {
            throw ServiceError.missingOAuthCallback
        }
        let values = Self.parseKeyValuePayload(fragment)
        guard let accessToken = values["access_token"], let refreshToken = values["refresh_token"] else {
            throw ServiceError.missingOAuthCallback
        }

        let user = try await fetchUser(accessToken: accessToken)
        return AppSession(
            accessToken: accessToken,
            refreshToken: refreshToken,
            userID: user.id,
            email: user.email,
            expiresAt: values["expires_in"].flatMap { Double($0) }.map { Date().addingTimeInterval($0) }
        )
    }

    func restoreSession(_ session: AppSession) async throws -> AppSession {
        let user = try await fetchUser(accessToken: session.accessToken)
        return AppSession(accessToken: session.accessToken, refreshToken: session.refreshToken, userID: user.id, email: user.email, expiresAt: session.expiresAt)
    }

    func fetchProfile(userID: String, accessToken: String) async throws -> UserProfile? {
        let request = try makeRequest(path: "profiles?user_id=eq.\(userID)&select=*", method: "GET", authenticated: true, bearerToken: accessToken)
        let (data, response) = try await urlSession.data(for: request)
        try validate(response: response, data: data)
        let profiles = try decode([UserProfile].self, from: data)
        return profiles.first
    }

    func ensureProfile(for session: AppSession, name: String? = nil) async throws -> UserProfile {
        if let profile = try await fetchProfile(userID: session.userID, accessToken: session.accessToken) {
            return profile
        }

        let body: [String: AnyEncodable] = [
            "id": AnyEncodable(session.userID),
            "full_name": AnyEncodable(name ?? session.email ?? "CriderGPT User"),
            "email": AnyEncodable(session.email ?? "")
        ]
        let request = try makeRequest(path: "profiles", method: "POST", authenticated: true, bearerToken: session.accessToken, body: body)
        let (data, response) = try await urlSession.data(for: request)
        try validate(response: response, data: data)
        let profiles = try decode([UserProfile].self, from: data)
        return profiles.first ?? UserProfile(id: session.userID, fullName: name, email: session.email, avatarURL: nil, phoneNumber: nil, smsEnabled: nil, role: nil)
    }

    func fetchSubscriptionState(userID: String, accessToken: String) async throws -> SubscriptionState {
        let plus = try await fetchPlanState(table: "user_subscriptions", userID: userID, accessToken: accessToken)
        let pro = try await fetchPlanState(table: "subscriptions", userID: userID, accessToken: accessToken)
        let iap = try await fetchPlanState(table: "iap_purchases", userID: userID, accessToken: accessToken)

        var state = SubscriptionState.free
        state.plusActive = plus.isActive
        state.proActive = pro.isActive || iap.isPro
        state.activePlan = state.proActive ? .pro : (state.plusActive ? .plus : .free)
        state.source = "backend"
        state.verifiedAt = Date()
        return state
    }

    func verifyPurchase(userID: String, accessToken: String, transactionID: String, originalTransactionID: String, productID: String, signedTransactionInfo: String) async throws -> SubscriptionState {
        let payload: [String: AnyEncodable] = [
            "user_id": AnyEncodable(userID),
            "transaction_id": AnyEncodable(transactionID),
            "original_transaction_id": AnyEncodable(originalTransactionID),
            "product_id": AnyEncodable(productID),
            "signed_transaction_info": AnyEncodable(signedTransactionInfo)
        ]
        let request = try makeEdgeFunctionRequest(name: "verify-iap", method: "POST", bearerToken: accessToken, body: payload)
        let (data, response) = try await urlSession.data(for: request)
        try validate(response: response, data: data)
        if let decoded = try? decode(SubscriptionState.self, from: data) {
            return decoded
        }
        return try await fetchSubscriptionState(userID: userID, accessToken: accessToken)
    }

    func updateProfile(_ profile: UserProfile, accessToken: String) async throws {
        let body: [String: AnyEncodable] = [
            "full_name": AnyEncodable(profile.fullName ?? ""),
            "email": AnyEncodable(profile.email ?? ""),
            "phone_number": AnyEncodable(profile.phoneNumber ?? ""),
            "sms_enabled": AnyEncodable(profile.smsEnabled ?? false),
            "role": AnyEncodable(profile.role ?? "user")
        ]
        let request = try makeRequest(path: "profiles?id=eq.\(profile.id)", method: "PATCH", authenticated: true, bearerToken: accessToken, body: body)
        let (data, response) = try await urlSession.data(for: request)
        try validate(response: response, data: data)
        _ = data
    }

    func listRows(table: String, accessToken: String, select: String = "*") async throws -> [[String: Any]] {
        let request = try makeRequest(path: "\(table)?select=\(select)", method: "GET", authenticated: true, bearerToken: accessToken)
        let (data, response) = try await urlSession.data(for: request)
        try validate(response: response, data: data)
        return try decodeJSONArray(from: data)
    }

    func callEdgeFunction(name: String, accessToken: String, payload: [String: AnyEncodable]) async throws -> Data {
        let request = try makeEdgeFunctionRequest(name: name, method: "POST", bearerToken: accessToken, body: payload)
        let (data, response) = try await urlSession.data(for: request)
        try validate(response: response, data: data)
        return data
    }

    func signOut(accessToken: String) async {
        guard let url = URL(string: "\(config.authBaseURL.absoluteString)/logout") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = commonHeaders.merging(["Authorization": "Bearer \(accessToken)"]) { current, _ in current }
        _ = try? await urlSession.data(for: request)
    }

    private func authenticate(url: URL, callbackScheme: String, presentationContextProvider: ASWebAuthenticationPresentationContextProviding) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackScheme) { callbackURL, error in
                if let callbackURL {
                    continuation.resume(returning: callbackURL)
                    return
                }
                continuation.resume(throwing: error ?? ServiceError.missingOAuthCallback)
            }
            session.presentationContextProvider = presentationContextProvider
            session.prefersEphemeralWebBrowserSession = false
            _ = session.start()
        }
    }

    private func fetchUser(accessToken: String) async throws -> SupabaseUser {
        let request = try makeRequest(path: "user", method: "GET", authenticated: true, bearerToken: accessToken)
        let (data, response) = try await urlSession.data(for: request)
        try validate(response: response, data: data)
        return try decode(SupabaseUser.self, from: data)
    }

    private func fetchPlanState(table: String, userID: String, accessToken: String) async throws -> (isActive: Bool, isPro: Bool) {
        let request = try makeRequest(path: "\(table)?user_id=eq.\(userID)&select=*", method: "GET", authenticated: true, bearerToken: accessToken)
        let (data, response) = try await urlSession.data(for: request)
        try validate(response: response, data: data)
        let rows = try decodeJSONArray(from: data)
        let activeValues = ["active", "trialing", "paid", "verified"]
        let isActive = rows.contains { row in
            let status = (row["status"] as? String)?.lowercased() ?? ""
            let plan = (row["plan"] as? String)?.lowercased() ?? ""
            return activeValues.contains(status) || plan == "plus" || plan == "pro" || (row["active"] as? Bool ?? false)
        }
        let isPro = rows.contains { row in
            let plan = (row["plan"] as? String)?.lowercased() ?? ""
            let productID = (row["product_id"] as? String)?.lowercased() ?? ""
            return plan == "pro" || productID.contains("pro")
        }
        return (isActive, isPro)
    }

    private func makeRequest(path: String, method: String, authenticated: Bool, bearerToken: String? = nil, body: [String: AnyEncodable]? = nil) throws -> URLRequest {
        guard config.supabaseAnonKey.isEmpty == false else {
            throw ServiceError.missingConfiguration
        }
        guard let url = URL(string: path, relativeTo: authenticated ? config.restBaseURL : config.authBaseURL) else {
            throw ServiceError.invalidResponse
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = commonHeaders.merging(authenticated ? ["Authorization": "Bearer \(bearerToken ?? config.supabaseAnonKey)"] : [:]) { current, _ in current }
        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        return request
    }

    private func makeEdgeFunctionRequest(name: String, method: String, bearerToken: String, body: [String: AnyEncodable]) throws -> URLRequest {
        guard let url = URL(string: name, relativeTo: config.functionsBaseURL) else {
            throw ServiceError.invalidResponse
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = commonHeaders.merging(["Authorization": "Bearer \(bearerToken)"]) { current, _ in current }
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw ServiceError.authorizationFailed(body.isEmpty ? "Backend request failed." : body)
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }

    private func decodeJSONArray(from data: Data) throws -> [[String: Any]] {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw ServiceError.parsingFailed
        }
        return json
    }

    static func parseKeyValuePayload(_ payload: String) -> [String: String] {
        payload
            .split(separator: "&")
            .reduce(into: [:]) { result, pair in
                let keyValue = pair.split(separator: "=", maxSplits: 1).map(String.init)
                guard keyValue.count == 2 else { return }
                result[keyValue[0]] = keyValue[1].removingPercentEncoding ?? keyValue[1]
            }
    }
}

struct AnyEncodable: Encodable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let string as String:
            try container.encode(string)
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let date as Date:
            try container.encode(ISO8601DateFormatter().string(from: date))
        default:
            try container.encodeNil()
        }
    }
}
