//
//  Typography.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

/// Typography system using SF Pro
extension Font {

    // MARK: - Display Fonts (Large Titles)

    /// Extra large display text (36pt)
    static let displayLarge = Font.system(size: 36, weight: .bold, design: .default)

    /// Medium display text (28pt)
    static let displayMedium = Font.system(size: 28, weight: .bold, design: .default)

    /// Small display text (24pt)
    static let displaySmall = Font.system(size: 24, weight: .bold, design: .default)

    // MARK: - Title Fonts

    /// Large title (24pt, bold)
    static let titleLarge = Font.system(size: 24, weight: .bold, design: .default)

    /// Medium title (20pt, semibold)
    static let titleMedium = Font.system(size: 20, weight: .semibold, design: .default)

    /// Small title (18pt, semibold)
    static let titleSmall = Font.system(size: 18, weight: .semibold, design: .default)

    // MARK: - Body Fonts

    /// Large body text (18pt)
    static let bodyLarge = Font.system(size: 18, weight: .regular, design: .default)

    /// Medium body text (16pt) - Default reading size
    static let bodyMedium = Font.system(size: 16, weight: .regular, design: .default)

    /// Small body text (14pt)
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)

    // MARK: - Label Fonts

    /// Large label (14pt, medium)
    static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)

    /// Medium label (12pt, medium)
    static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)

    /// Small label (10pt, medium)
    static let labelSmall = Font.system(size: 10, weight: .medium, design: .default)

    // MARK: - Caption Fonts

    /// Large caption (12pt)
    static let captionLarge = Font.system(size: 12, weight: .regular, design: .default)

    /// Small caption (10pt)
    static let captionSmall = Font.system(size: 10, weight: .regular, design: .default)
}

// MARK: - Text Style Modifiers

extension View {
    /// Apply display large style
    func displayLarge() -> some View {
        self.font(.displayLarge)
            .foregroundColor(.textPrimary)
    }

    /// Apply display medium style
    func displayMedium() -> some View {
        self.font(.displayMedium)
            .foregroundColor(.textPrimary)
    }

    /// Apply title large style
    func titleLarge() -> some View {
        self.font(.titleLarge)
            .foregroundColor(.textPrimary)
    }

    /// Apply title medium style
    func titleMedium() -> some View {
        self.font(.titleMedium)
            .foregroundColor(.textPrimary)
    }

    /// Apply body medium style (default reading)
    func bodyMedium() -> some View {
        self.font(.bodyMedium)
            .foregroundColor(.textPrimary)
            .lineSpacing(8) // 1.6x line height
    }

    /// Apply body large style
    func bodyLarge() -> some View {
        self.font(.bodyLarge)
            .foregroundColor(.textPrimary)
            .lineSpacing(8)
    }

    /// Apply label style
    func labelStyle() -> some View {
        self.font(.labelMedium)
            .foregroundColor(.textSecondary)
    }

    /// Apply caption style
    func captionStyle() -> some View {
        self.font(.captionLarge)
            .foregroundColor(.textTertiary)
    }
}

// MARK: - Line Height Extension

extension View {
    /// Apply line spacing for comfortable reading (1.6x)
    func readableLineSpacing() -> some View {
        self.lineSpacing(8)
    }
}
