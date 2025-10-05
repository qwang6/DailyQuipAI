//
//  Colors.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

/// App color palette
extension Color {

    // MARK: - Brand Colors

    /// Primary brand color - Warm gold representing "light"
    static let brandPrimary = Color(hex: "F5A623")

    /// Brand gradient colors
    static let brandGradientStart = Color(hex: "F5A623")
    static let brandGradientEnd = Color(hex: "FFB84D")

    // MARK: - Category Colors

    /// Category-specific colors (from Category model, duplicated here for convenience)
    struct CategoryColors {
        static let history = Color(hex: "F5A623") // Amber orange
        static let science = Color(hex: "7ED321") // Green
        static let art = Color(hex: "BD10E0") // Violet
        static let life = Color(hex: "FF9500") // Orange
        static let finance = Color(hex: "D4AF37") // Gold
        static let philosophy = Color(hex: "4A90E2") // Blue
    }

    // MARK: - Semantic Colors

    /// Success state color
    static let success = Color(hex: "52C41A")

    /// Warning state color
    static let warning = Color(hex: "FAAD14")

    /// Error state color
    static let error = Color(hex: "F5222D")

    /// Info state color
    static let info = Color(hex: "1890FF")

    // MARK: - Text Colors

    /// Primary text color (adapts to dark mode)
    static let textPrimary = Color.primary

    /// Secondary text color
    static let textSecondary = Color.secondary

    /// Tertiary text color (hints, placeholders)
    static let textTertiary = Color(light: Color(hex: "999999"), dark: Color(hex: "666666"))

    // MARK: - Background Colors

    /// Primary background color
    static let backgroundPrimary = Color(light: .white, dark: .black)

    /// Secondary background color (cards, panels)
    static let backgroundSecondary = Color(light: Color(hex: "F7F7F7"), dark: Color(hex: "1C1C1E"))

    /// Tertiary background color
    static let backgroundTertiary = Color(light: Color(hex: "EEEEEE"), dark: Color(hex: "2C2C2E"))

    // MARK: - Border & Divider Colors

    /// Standard divider color
    static let divider = Color(light: Color(hex: "EEEEEE"), dark: Color(hex: "333333"))

    /// Border color for inputs and cards
    static let border = Color(light: Color(hex: "E0E0E0"), dark: Color(hex: "3A3A3C"))

    // MARK: - Overlay Colors

    /// Overlay for modals and sheets
    static let overlay = Color.black.opacity(0.4)

    /// Card shadow color
    static let shadow = Color.black.opacity(0.1)
}

// MARK: - Color Utilities

extension Color {
    /// Initialize color from hex string
    /// - Parameter hex: Hex color string (e.g., "FF0000" or "#FF0000")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Create a color that adapts to light and dark mode
    /// - Parameters:
    ///   - light: Color for light mode
    ///   - dark: Color for dark mode
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}

// MARK: - Gradient Extensions

extension LinearGradient {
    /// Brand gradient
    static let brand = LinearGradient(
        colors: [.brandGradientStart, .brandGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Category gradient
    static func category(_ category: Category) -> LinearGradient {
        let color = category.color
        return LinearGradient(
            colors: [color, color.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
