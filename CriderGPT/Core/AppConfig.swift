import Foundation

struct AppConfig {
    let supabaseURL: URL
    let supabaseAnonKey: String
    let appleBundleIdentifier: String

    init(bundle: Bundle = .main) {
        let urlString = bundle.object(forInfoDictionaryKey: "SUPABASE_URL") as? String ?? ""
        let keyString = bundle.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String ?? ""

        self.supabaseURL = URL(
            string: urlString.isEmpty ? "https://example.supabase.co" : urlString
        ) ?? URL(string: "https://example.supabase.co")!

        self.supabaseAnonKey = keyString
        self.appleBundleIdentifier = bundle.bundleIdentifier ?? "app.cridergpt.ios"
    }

    var authBaseURL: URL {
        supabaseURL.appendingPathComponent("auth/v1")
    }

    var restBaseURL: URL {
        supabaseURL.appendingPathComponent("rest/v1")
    }

    var storageBaseURL: URL {
        supabaseURL.appendingPathComponent("storage/v1")
    }

    var functionsBaseURL: URL {
        supabaseURL.appendingPathComponent("functions/v1")
    }
}
