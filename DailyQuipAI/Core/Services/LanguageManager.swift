//
//  LanguageManager.swift
//  DailyQuipAI
//
//  Language management service for i18n support
//

import Foundation
import SwiftUI
import Combine

/// Supported languages in the app
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case chinese = "zh-Hans"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .chinese:
            return "简体中文"
        }
    }

    var localizedKey: String {
        switch self {
        case .english:
            return "settings.language.english"
        case .chinese:
            return "settings.language.chinese"
        }
    }
}

/// Language manager for handling app localization
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "appLanguage")
            // Update the bundle for runtime language switching
            updateBundle()
        }
    }

    private var bundle: Bundle = .main

    private init() {
        // Load saved language preference
        if let savedLanguage = UserDefaults.standard.string(forKey: "appLanguage"),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            // Auto-detect system language
            self.currentLanguage = Self.detectSystemLanguage()
        }

        updateBundle()
    }

    /// Detect the system language and map to supported languages
    private static func detectSystemLanguage() -> AppLanguage {
        let preferredLanguages = Locale.preferredLanguages

        for languageCode in preferredLanguages {
            // Check for Chinese (Simplified)
            if languageCode.hasPrefix("zh-Hans") || languageCode.hasPrefix("zh-CN") {
                return .chinese
            }
            // Check for English
            if languageCode.hasPrefix("en") {
                return .english
            }
        }

        // Default to English if no match
        return .english
    }

    /// Change the app language
    func changeLanguage(to language: AppLanguage) {
        currentLanguage = language
    }

    /// Update the bundle for the current language
    private func updateBundle() {
        if let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            self.bundle = bundle
        } else {
            self.bundle = .main
        }
    }

    /// Get localized string for a key
    func localizedString(_ key: String, comment: String = "") -> String {
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }

    /// Get localized string with format arguments
    func localizedString(_ key: String, _ args: CVarArg...) -> String {
        let format = localizedString(key)
        return String(format: format, arguments: args)
    }
}

// MARK: - String Extension for Easy Localization

extension String {
    /// Returns the localized version of this string
    var localized: String {
        return LanguageManager.shared.localizedString(self)
    }

    /// Returns the localized version of this string with arguments
    func localized(_ args: CVarArg...) -> String {
        let format = LanguageManager.shared.localizedString(self)
        return String(format: format, arguments: args)
    }
}

// MARK: - Environment Key for Language Manager

struct LanguageManagerKey: EnvironmentKey {
    static let defaultValue = LanguageManager.shared
}

extension EnvironmentValues {
    var languageManager: LanguageManager {
        get { self[LanguageManagerKey.self] }
        set { self[LanguageManagerKey.self] = newValue }
    }
}
