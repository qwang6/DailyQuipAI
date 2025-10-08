//
//  SubscriptionManager.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import Foundation
import Combine

/// Manages user subscription state and card limits
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published private(set) var subscriptionType: SubscriptionType = .free
    @Published private(set) var cardsViewedToday: Int = 0

    private let subscriptionTypeKey = "userSubscriptionType"
    private let cardsViewedTodayKey = "cardsViewedToday"
    private let lastResetDateKey = "lastCardsResetDate"

    private init() {
        loadSubscription()
        resetDailyCountIfNeeded()

        // Debug logging
        print("🔧 SubscriptionManager initialized")
        print("   - Subscription: \(subscriptionType.rawValue)")
        print("   - Cards viewed today: \(cardsViewedToday)")
        print("   - Daily limit: \(dailyCardLimit?.description ?? "unlimited")")
        print("   - Can view more: \(canViewMoreCards)")
    }

    // MARK: - Subscription Management

    /// Load subscription from storage
    private func loadSubscription() {
        if let typeString = UserDefaults.standard.string(forKey: subscriptionTypeKey),
           let type = SubscriptionType(rawValue: typeString) {
            subscriptionType = type
        } else {
            subscriptionType = .free  // Default to free
        }

        cardsViewedToday = UserDefaults.standard.integer(forKey: cardsViewedTodayKey)
    }

    /// Update subscription type
    func updateSubscription(to type: SubscriptionType) {
        subscriptionType = type
        UserDefaults.standard.set(type.rawValue, forKey: subscriptionTypeKey)
        print("✅ Subscription updated to: \(type.rawValue)")
    }

    /// Restore previous purchases
    /// Returns true if any purchases were restored, false otherwise
    @MainActor
    func restorePurchases() async throws -> Bool {
        // In a real app, this would use StoreKit to restore purchases
        // For now, we'll check if there's a stored subscription
        print("🔄 Attempting to restore purchases...")

        // Simulate restore by checking UserDefaults
        // In production, this would call:
        // try await AppStore.sync()
        // or Product.LatestTransaction for each product

        if let typeString = UserDefaults.standard.string(forKey: subscriptionTypeKey),
           let type = SubscriptionType(rawValue: typeString),
           type != .free {
            print("✅ Restored subscription: \(type.rawValue)")
            subscriptionType = type
            return true
        }

        print("ℹ️ No purchases to restore")
        return false
    }

    // MARK: - Daily Limit Management

    /// Check if user can view more cards today
    var canViewMoreCards: Bool {
        guard let limit = subscriptionType.dailyCardLimit else {
            return true  // Premium users have no limit
        }
        return cardsViewedToday < limit
    }

    /// Get remaining cards for today
    var remainingCardsToday: Int? {
        guard let limit = subscriptionType.dailyCardLimit else {
            return nil  // Premium users have no limit
        }
        return max(0, limit - cardsViewedToday)
    }

    /// Increment cards viewed count
    func incrementCardsViewed() {
        cardsViewedToday += 1
        UserDefaults.standard.set(cardsViewedToday, forKey: cardsViewedTodayKey)
        print("📊 Cards viewed today: \(cardsViewedToday)")
    }

    /// Reset daily count if it's a new day
    private func resetDailyCountIfNeeded() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastResetDate = UserDefaults.standard.object(forKey: lastResetDateKey) as? Date {
            let lastReset = calendar.startOfDay(for: lastResetDate)

            print("📅 Date check:")
            print("   - Today: \(today)")
            print("   - Last reset: \(lastReset)")
            print("   - Is new day: \(today > lastReset)")

            if today > lastReset {
                // New day - reset count
                print("🔄 New day detected, resetting card count")
                resetDailyCount()
            } else {
                print("📆 Same day, keeping count at \(cardsViewedToday)")
            }
        } else {
            // First time - set last reset date
            print("🆕 First launch - initializing reset date")
            UserDefaults.standard.set(Date(), forKey: lastResetDateKey)
        }
    }

    /// Reset daily card count
    func resetDailyCount() {
        cardsViewedToday = 0
        UserDefaults.standard.set(0, forKey: cardsViewedTodayKey)
        UserDefaults.standard.set(Date(), forKey: lastResetDateKey)
        print("🔄 Daily card count reset")
    }

    // MARK: - Premium Features

    /// Check if user is premium
    var isPremium: Bool {
        subscriptionType.isPremium
    }

    /// Get daily card limit
    var dailyCardLimit: Int? {
        subscriptionType.dailyCardLimit
    }

    // MARK: - Testing Helpers

    #if DEBUG
    /// Switch to free subscription (for testing)
    func switchToFree() {
        updateSubscription(to: .free)
    }

    /// Switch to premium subscription (for testing)
    func switchToPremium() {
        updateSubscription(to: .lifetime)
    }

    /// Reset viewed count (for testing)
    func resetViewedCount() {
        resetDailyCount()
    }

    /// Simulate yesterday's reset date (for testing next-day reset)
    func simulateYesterday() {
        let calendar = Calendar.current
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) {
            UserDefaults.standard.set(yesterday, forKey: lastResetDateKey)
            print("🧪 Simulated last reset as yesterday: \(yesterday)")
            print("   Next app launch will trigger reset")
        }
    }

    /// Check if reset will happen (for testing)
    func checkResetStatus() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastResetDate = UserDefaults.standard.object(forKey: lastResetDateKey) as? Date {
            let lastReset = calendar.startOfDay(for: lastResetDate)
            let willReset = today > lastReset

            print("🔍 Reset Status Check:")
            print("   - Today: \(today)")
            print("   - Last reset: \(lastReset)")
            print("   - Will reset on next launch: \(willReset)")
            print("   - Current cards viewed: \(cardsViewedToday)")
        } else {
            print("🔍 Reset Status Check: No reset date set")
        }
    }
    #endif
}
