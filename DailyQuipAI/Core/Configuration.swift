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
        // 1. Xcode scheme environment variable (for development)
        // 2. .env file in project root (for local development)
        // 3. Empty string (will cause error - intentional)

        if let envKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"], !envKey.isEmpty {
            return envKey
        }

        if let envFileKey = loadFromEnvFile(key: "GEMINI_API_KEY"), !envFileKey.isEmpty {
            return envFileKey
        }

        #if DEBUG
        print("⚠️ WARNING: No Gemini API key configured!")
        print("💡 Configure via:")
        print("   1. Xcode → Product → Scheme → Edit Scheme → Run → Environment Variables")
        print("      Add: GEMINI_API_KEY = your_api_key_here")
        print("   2. Create .env file in project root with:")
        print("      GEMINI_API_KEY=your_api_key_here")
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
