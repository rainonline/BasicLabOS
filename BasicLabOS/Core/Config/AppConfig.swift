import Foundation

enum AppConfig {
    #if DEBUG
    nonisolated static let apiBaseURL = URL(string: "http://127.0.0.1:8000")!
    #else
    nonisolated static let apiBaseURL = URL(string: "https://api.basiclab.example.com")!
    #endif

    nonisolated static let requestTimeout: TimeInterval = 10
}
