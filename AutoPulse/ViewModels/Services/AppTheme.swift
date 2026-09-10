import SwiftUI

struct AppTheme {
    // Backgrounds
    static let backgroundPrimary = Color(hex: "#0d1117")
    static let backgroundSecondary = Color(hex: "#0f1623")
    static let backgroundCard = Color(hex: "#141c2e")
    static let backgroundInput = Color(hex: "#1a2340")

    // Accent
    static let accent = Color(hex: "#38bdf8")
    static let accentGlow = Color(hex: "#38bdf8").opacity(0.15)
    static let accentSecondary = Color(hex: "#3b82f6")

    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "#8b9dc3")
    static let textMuted = Color(hex: "#2d3a55")

    // Status
    static let success = Color(hex: "#10b981")
    static let warning = Color(hex: "#f59e0b")
    static let danger = Color(hex: "#ef4444")
    static let info = Color(hex: "#38bdf8")

    // Card border gradient colors
    static let cardBorderStart = Color(hex: "#38bdf8")
    static let cardBorderEnd = Color(hex: "#3b82f6")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
