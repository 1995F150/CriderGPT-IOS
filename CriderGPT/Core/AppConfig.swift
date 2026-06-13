import Foundation

struct AppConfig {
    let supabaseURL: URL
    let supabaseAnonKey: String
    let appleBundleIdentifier: String

    init(bundle: Bundle = .main) {
        let urlString = bundle.object(forInfoDictionaryKey: "SUPABASE_URL") as? String ?? ""
        let keyString = bundle.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String ?? ""
        self.supabaseURL = URL(string: urlString.isEmpty ? "https://example.supabase.co" : urlString) ?? URL(string: "https://example.supabase.co")!
        self.supabaseAnonKey = keyString
        self.appleBundleIdentifier = bundle.bundleIdentifier ?? "app.cridergpt.ios"
    }

    var authBaseURL: URL {import Foundation

struct AppConfig {
    let supabaseURL: URL
    let supabaseAnonKey: String
    let appleBundleIdentifier: String

    init(bundle: Bundle = .main) {
        let urlString = bundle.object(forInfoDictionaryKey: "SUPABASE_URL") as? String ?? ""
        let keyString = bundle.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String ?? ""
        
        // Use provided Supabase URL as fallback
        self.supabaseURL = URL(string: urlString.isEmpty ? "https://udpldrrpebdyuiqdtqnq.supabase.co" : urlString) ?? URL(string: "https://udpldrrpebdyuiqdtqnq.supabase.co")!
        
        // Use provided Anon Key as fallback
        self.supabaseAnonKey = keyString.isEmpty ? "sb_publishable_jK0QrNtV6HytstYsr5HRsA_E7B3PLKL" : keyString
        
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
}
        supabaseURL.appendingPathComponent("auth/v1")
    }

    var restBaseURL: URL {
        supabaseURL.appendingPathComponent("rest/v1")
    }

    var functionsBaseURL: URL {
        supabaseURL.appendingPathComponent("functions/v1")
    }
}
