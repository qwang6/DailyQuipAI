//
//  SubscriptionManager.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import Foundation
import Combine
import StoreKit

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

    /// Restore previous purchases using StoreKit 2
    /// Returns true if any purchases were restored, false otherwise
    @MainActor
    func restorePurchases() async throws -> Bool {
        print("🔄 Attempting to restore purchases via StoreKit...")

        // Sync with App Store to get latest transactions
        try await AppStore.sync()

        var restoredType: SubscriptionType?

        // Check for valid transactions for each product ID
        let productIDs = [
            "com.qwang.dailyquipai.premium.monthly",
            "com.qwang.dailyquipai.premium.annual",
            "com.qwang.dailyquipai.premium.lifetime"
        ]

        for productID in productIDs {
            // Check for latest verified transaction
            if let transaction = await Transaction.latest(for: productID) {
                // Verify the transaction
                switch transaction {
                case .verified(let verifiedTransaction):
                    // Check if transaction is not expired/revoked
                    if verifiedTransaction.revocationDate == nil {
                        // Map product ID to subscription type
                        if productID.contains("monthly") {
                            restoredType = .monthly
                            print("✅ Restored Monthly subscription")
                        } else if productID.contains("annual") {
                            restoredType = .annual
                            print("✅ Restored Annual subscription")
                        } else if productID.contains("lifetime") {
                            restoredType = .lifetime
                            print("✅ Restored Lifetime subscription")
                        }

                        // Finish the transaction
                        await verifiedTransaction.finish()
                        break // Found a valid subscription
                    }
                case .unverified:
                    print("⚠️ Unverified transaction for \(productID)")
                }
            }
        }

        // Update subscription if we found one
        if let type = restoredType {
            updateSubscription(to: type)
            return true
        }

        print("ℹ️ No valid purchases to restore")
        return false
    }

    // MARK: - Daily Limit Management

    /// Check if user can view more cards today
    var canViewMoreCards: Bool {
        return true  // No limits - completely free app
    }

    /// Get remaining cards for today
    var remainingCardsToday: Int? {
        return nil  // No limits - completely free app
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
