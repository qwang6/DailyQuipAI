//
//  Configuration.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import Foundation

/// Centralized configuration management for API keys and environment variables
enum Configuration {

    // MARK: - Environment Variables

    /// Get Gemini API key from environment or .env file
    static var geminiAPIKey: String {
        // Priority:
        // 1. Info.plist (for production/archive builds)
        // 2. Xcode scheme environment variable (for development)
        // 3. .env file in project root (for local development)
        // 4. Empty string (will cause error - intentional)

        // Check Info.plist first (for production builds)
        if let plistKey = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String, !plistKey.isEmpty {
            return plistKey
        }

        // Check environment variable (Xcode scheme)
        if let envKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"], !envKey.isEmpty {
            return envKey
        }

        // Check .env file (local development)
        if let envFileKey = loadFromEnvFile(key: "GEMINI_API_KEY"), !envFileKey.isEmpty {
            return envFileKey
        }

        #if DEBUG
        print("⚠️ WARNING: No Gemini API key configured!")
        print("💡 Configure via:")
        print("   1. For Archive/Production: Add to Info.plist")
        print("      Key: GEMINI_API_KEY, Value: your_api_key_here")
        print("   2. For Development: Create .env file in project root with:")
        print("      GEMINI_API_KEY=your_api_key_here")
        print("   3. Or Xcode → Scheme → Environment Variables")
        #endif

        return ""
    }

    // MARK: - Private Helpers

    /// Load value from .env file
    /// - Parameter key: The environment variable key
    /// - Returns: The value if found, nil otherwise
    private static func loadFromEnvFile(key: String) -> String? {
        // Try to find .env file in common locations
        let possiblePaths = [
            // Project root (most common)
            URL(fileURLWithPath: #file)
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appendingPathComponent(".env"),

            // Parent directory
            URL(fileURLWithPath: #file)
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appendingPathComponent(".env")
        ]

        for envPath in possiblePaths {
            if let envContent = try? String(contentsOf: envPath, encoding: .utf8) {
                let lines = envContent.components(separatedBy: .newlines)

                for line in lines {
                    let trimmedLine = line.trimmingCharacters(in: .whitespaces)

                    // Skip comments and empty lines
                    guard !trimmedLine.isEmpty && !trimmedLine.hasPrefix("#") else {
                        continue
                    }

                    // Parse KEY=VALUE format
                    let parts = trimmedLine.components(separatedBy: "=")
                    guard parts.count >= 2 else { continue }

                    let envKey = parts[0].trimmingCharacters(in: .whitespaces)
                    let envValue = parts[1...].joined(separator: "=").trimmingCharacters(in: .whitespaces)

                    if envKey == key {
                        #if DEBUG
                        print("✅ Loaded \(key) from .env file: \(envPath.path)")
                        #endif
                        return envValue
                    }
                }
            }
        }

        return nil
    }
}
