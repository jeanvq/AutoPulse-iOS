import Foundation

struct Config {
    static let anthropicAPIKey = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] ?? "YOUR_API_KEY_HERE"
}
