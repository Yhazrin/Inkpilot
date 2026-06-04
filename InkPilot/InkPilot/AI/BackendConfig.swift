import Foundation

/// Where the iPad finds the local FastAPI backend.
///
/// Update `baseURL` to your Mac's LAN IP. Print it on the Mac by
/// running `ifconfig | grep "inet "` and picking the en0/en1 entry
/// that's not 127.0.0.1.
///
/// The Info.plist already allows HTTP to local network ranges via
/// `NSAllowsLocalNetworking = true`, so plain `http://` works.
enum BackendConfig {
    /// The Mac's LAN IP and the port uvicorn is bound to.
    static let baseURL: URL = {
        if let raw = Bundle.main.object(forInfoDictionaryKey: "INKPILOT_BACKEND_URL") as? String,
           let url = URL(string: raw) {
            return url
        }
        return URL(string: "http://192.168.1.42:8000")!
    }()

    /// Whether the backend is configured and reachable.
    /// Used to decide between NetworkSuggestionService and MockSuggestionService.
    static var isBackendAvailable: Bool {
        // If the URL is the default placeholder, assume offline
        return baseURL.host != "192.168.1.42"
    }
}
