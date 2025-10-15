//
//  Category.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

/// Knowledge card categories
enum Category: String, Codable, CaseIterable, Identifiable {
    case history = "History"
    case science = "Science"
    case art = "Art"
    case life = "Life"
    case finance = "Finance"
    case philosophy = "Philosophy"

    var id: String { rawValue }

    /// Localized display name
    var displayName: String {
        switch self {
        case .history:
            return "category.history".localized
        case .science:
            return "category.science".localized
        case .art:
            return "category.art".localized
        case .life:
            return "category.life".localized
        case .finance:
            return "category.finance".localized
        case .philosophy:
            return "category.philosophy".localized
        }
    }

    /// SF Symbol icon name for this category
    var icon: String {
        switch self {
        case .history:
            return "books.vertical.fill"
        case .science:
            return "atom"
        case .art:
            return "paintpalette.fill"
        case .life:
            return "leaf.fill"
        case .finance:
            return "dollarsign.circle.fill"
        case .philosophy:
            return "brain.head.profile"
        }
    }

    /// Primary color for this category
    var color: Color {
        switch self {
        case .history:
            return Color(red: 0.96, green: 0.65, blue: 0.14) // Amber orange #F5A623
        case .science:
            return Color(red: 0.49, green: 0.83, blue: 0.13) // Green #7ED321
        case .art:
            return Color(red: 0.74, green: 0.06, blue: 0.88) // Violet #BD10E0
        case .life:
            return Color(red: 1.00, green: 0.58, blue: 0.00) // Orange #FF9500
        case .finance:
            return Color(red: 0.83, green: 0.69, blue: 0.22) // Gold #D4AF37
        case .philosophy:
            return Color(red: 0.29, green: 0.56, blue: 0.89) // Blue #4A90E2
        }
    }

    /// Glassmorphism gradient for category (iOS 18 style)
    var glassGradient: LinearGradient {
        switch self {
        case .history:
            // Warm amber to bronze
            return LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.71, blue: 0.35).opacity(0.85),  // Light amber
                    Color(red: 0.85, green: 0.52, blue: 0.20).opacity(0.75),  // Deep amber
                    Color(red: 0.65, green: 0.35, blue: 0.15).opacity(0.65)   // Bronze
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .science:
            // Vibrant cyan to teal
            return LinearGradient(
                colors: [
                    Color(red: 0.40, green: 0.85, blue: 0.95).opacity(0.85),  // Light cyan
                    Color(red: 0.20, green: 0.70, blue: 0.85).opacity(0.75),  // Ocean blue
                    Color(red: 0.15, green: 0.55, blue: 0.65).opacity(0.65)   // Deep teal
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .art:
            // Purple to magenta
            return LinearGradient(
                colors: [
                    Color(red: 0.85, green: 0.45, blue: 0.95).opacity(0.85),  // Light purple
                    Color(red: 0.70, green: 0.30, blue: 0.85).opacity(0.75),  // Purple
                    Color(red: 0.55, green: 0.20, blue: 0.70).opacity(0.65)   // Deep magenta
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .life:
            // Fresh green to mint
            return LinearGradient(
                colors: [
                    Color(red: 0.50, green: 0.90, blue: 0.60).opacity(0.85),  // Light mint
                    Color(red: 0.35, green: 0.75, blue: 0.50).opacity(0.75),  // Fresh green
                    Color(red: 0.25, green: 0.60, blue: 0.40).opacity(0.65)   // Forest green
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .finance:
            // Luxury gold to rose gold
            return LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.85, blue: 0.55).opacity(0.85),  // Light gold
                    Color(red: 0.90, green: 0.70, blue: 0.45).opacity(0.75),  // Gold
                    Color(red: 0.75, green: 0.50, blue: 0.35).opacity(0.65)   // Rose gold
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .philosophy:
            // Deep blue to indigo
            return LinearGradient(
                colors: [
                    Color(red: 0.55, green: 0.70, blue: 0.95).opacity(0.85),  // Light blue
                    Color(red: 0.40, green: 0.55, blue: 0.85).opacity(0.75),  // Royal blue
                    Color(red: 0.30, green: 0.40, blue: 0.70).opacity(0.65)   // Deep indigo
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    /// Accent color for glass effect highlights
    var accentColor: Color {
        switch self {
        case .history:
            return Color(red: 1.0, green: 0.85, blue: 0.60)
        case .science:
            return Color(red: 0.60, green: 0.95, blue: 1.0)
        case .art:
            return Color(red: 0.95, green: 0.70, blue: 1.0)
        case .life:
            return Color(red: 0.70, green: 1.0, blue: 0.80)
        case .finance:
            return Color(red: 1.0, green: 0.90, blue: 0.70)
        case .philosophy:
            return Color(red: 0.70, green: 0.85, blue: 1.0)
        }
    }

    /// Short description of this category
    var description: String {
        switch self {
        case .history:
            return "Historical events, figures, and cultural phenomena"
        case .science:
            return "Physics, chemistry, biology, astronomy, and technology"
        case .art:
            return "Painting, music, architecture, film, and design"
        case .life:
            return "Health, psychology, sociology, and geography"
        case .finance:
            return "Economics, investment strategies, and financial planning"
        case .philosophy:
            return "Quotes, wisdom, and ways of thinking"
        }
    }
}
