//
//  ThemeManager.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import SwiftUI
import Combine

/// Theme manager for app-wide theme settings
class ThemeManager: ObservableObject {

    /// Shared instance
    static let shared = ThemeManager()

    /// Current theme setting
    @Published var currentTheme: Theme {
        didSet {
            saveTheme()
        }
    }

    private let themeKey = "app.theme"

    private init() {
        // Load saved theme or default to system
        if let savedTheme = UserDefaults.standard.string(forKey: themeKey),
           let theme = Theme(rawValue: savedTheme) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .system
        }
    }

    /// Save theme preference
    private func saveTheme() {
        UserDefaults.standard.set(currentTheme.rawValue, forKey: themeKey)
    }

    /// Get color scheme for current theme
    var colorScheme: ColorScheme? {
        switch currentTheme {
        case .system:
            return nil // Use system default
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

// MARK: - View Extension

extension View {
    /// Apply theme to view
    func themedAppearance() -> some View {
        self.preferredColorScheme(ThemeManager.shared.colorScheme)
    }
}
