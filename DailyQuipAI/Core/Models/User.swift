//
//  User.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import Foundation

/// User subscription type
enum SubscriptionType: String, Codable, Equatable {
    case free = "Free"
    case monthly = "Monthly"
    case annual = "Annual"
    case lifetime = "Lifetime"

    /// Whether this is a paid subscription
    var isPremium: Bool {
        switch self {
        case .free:
            return false
        case .monthly, .annual, .lifetime:
            return true
        }
    }

    /// Daily card limit for this subscription type
    var dailyCardLimit: Int? {
        switch self {
        case .free:
            return 5  // Free users: 5 cards per day
        case .monthly, .annual, .lifetime:
            return nil  // Premium users: unlimited
        }
    }
}

/// User profile and preferences
struct User: Identifiable, Codable, Equatable {
    let id: UUID
    var username: String
    var email: String
    var interests: [Category]
    var streak: Int
    var totalCardsLearned: Int
    var settings: UserSettings
    var subscriptionType: SubscriptionType
    var subscriptionExpiryDate: Date?  // For monthly/annual subscriptions
    let createdAt: Date

    /// Increment the daily streak
    mutating func incrementStreak() {
        streak += 1
    }

    /// Reset streak to 0 (when user breaks their streak)
    mutating func resetStreak() {
        streak = 0
    }

    /// Increment total cards learned
    mutating func addCardLearned() {
        totalCardsLearned += 1
    }

    /// Check if user has an active streak
    var hasActiveStreak: Bool {
        streak > 0
    }

    /// Get streak milestone (7, 30, 100, etc.)
    var streakMilestone: Int? {
        let milestones = [7, 30, 100, 365]
        return milestones.last(where: { streak >= $0 })
    }

    /// Check if user is premium (paid subscription)
    var isPremium: Bool {
        subscriptionType.isPremium
    }

    /// Get daily card limit for this user
    var dailyCardLimit: Int? {
        subscriptionType.dailyCardLimit
    }

    /// Check if subscription is active (for monthly/annual)
    var isSubscriptionActive: Bool {
        switch subscriptionType {
        case .free:
            return true  // Free is always "active"
        case .lifetime:
            return true  // Lifetime never expires
        case .monthly, .annual:
            guard let expiryDate = subscriptionExpiryDate else { return false }
            return expiryDate > Date()
        }
    }
}

/// User settings and preferences
struct UserSettings: Codable, Equatable {
    var notificationTime: Date
    var notificationEnabled: Bool
    var theme: Theme
    var dailyGoal: Int // number of cards per day

    /// Default settings for new users
    static var `default`: UserSettings {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 8 // 8 AM default
        components.minute = 0

        return UserSettings(
            notificationTime: calendar.date(from: components) ?? Date(),
            notificationEnabled: true,
            theme: .system,
            dailyGoal: 3
        )
    }
}

/// App theme options
enum Theme: String, Codable, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var displayName: String {
        switch self {
        case .system:
            return "settings.theme.system".localized
        case .light:
            return "settings.theme.light".localized
        case .dark:
            return "settings.theme.dark".localized
        }
    }
}

// MARK: - Mock Data for Testing
#if DEBUG
extension User {
    static func mock(
        id: UUID = UUID(),
        username: String = "Alex",
        streak: Int = 7,
        totalCardsLearned: Int = 42,
        subscriptionType: SubscriptionType = .free
    ) -> User {
        User(
            id: id,
            username: username,
            email: "alex@example.com",
            interests: [.history, .science, .philosophy],
            streak: streak,
            totalCardsLearned: totalCardsLearned,
            settings: .default,
            subscriptionType: subscriptionType,
            subscriptionExpiryDate: subscriptionType == .annual ? Date().addingTimeInterval(365 * 24 * 60 * 60) : nil,
            createdAt: Date().addingTimeInterval(-30 * 24 * 60 * 60) // 30 days ago
        )
    }

    static var mockFree: User {
        mock(subscriptionType: .free)
    }

    static var mockPremium: User {
        mock(subscriptionType: .lifetime)
    }
}
#endif
