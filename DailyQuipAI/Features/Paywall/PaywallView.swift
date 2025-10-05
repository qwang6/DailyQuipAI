//
//  PaywallView.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

/// Paywall view to encourage free users to upgrade
struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    let onUpgrade: (SubscriptionType) -> Void
    let onDismiss: (() -> Void)?

    init(onUpgrade: @escaping (SubscriptionType) -> Void, onDismiss: (() -> Void)? = nil) {
        self.onUpgrade = onUpgrade
        self.onDismiss = onDismiss
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.brandPrimary, Color.brandPrimary.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Spacer()

                // Icon
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .padding(.bottom, Spacing.md)

                // Title
                Text("You've reached your daily limit!")
                    .font(.displayMedium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                // Subtitle
                Text("Upgrade to Premium to continue learning")
                    .font(.bodyLarge)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

                // Features
                VStack(alignment: .leading, spacing: Spacing.md) {
                    FeatureRow(
                        icon: "infinity",
                        title: "Unlimited Cards",
                        description: "Learn as much as you want, every day"
                    )

                    FeatureRow(
                        icon: "sparkles",
                        title: "All Categories",
                        description: "Access all knowledge categories"
                    )

                    FeatureRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Advanced Analytics",
                        description: "Track your learning progress"
                    )
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.lg)
                .background(Color.white.opacity(0.15))
                .cornerRadius(CornerRadius.xlarge)
                .padding(.horizontal)

                Spacer()

                // Pricing options
                VStack(spacing: Spacing.md) {
                    PricingButton(
                        title: "Monthly",
                        price: "$0.99/month",
                        subscriptionType: .monthly,
                        onSelect: onUpgrade
                    )

                    PricingButton(
                        title: "Annual",
                        price: "$9.99/year",
                        badge: "Save 17%",
                        subscriptionType: .annual,
                        onSelect: onUpgrade
                    )

                    PricingButton(
                        title: "Lifetime",
                        price: "$19.99 once",
                        badge: "Best Value",
                        subscriptionType: .lifetime,
                        onSelect: onUpgrade
                    )
                }
                .padding(.horizontal)

                // Close button
                Button(action: {
                    onDismiss?()
                    dismiss()
                }) {
                    Text("Maybe Later")
                        .font(.bodyMedium)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, Spacing.lg)
            }
            .padding(.vertical, Spacing.xxl)
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(title)
                    .font(.labelLarge)
                    .foregroundColor(.white)

                Text(description)
                    .font(.captionLarge)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()
        }
    }
}

// MARK: - Pricing Button

struct PricingButton: View {
    let title: String
    let price: String
    let badge: String?
    let subscriptionType: SubscriptionType
    let onSelect: (SubscriptionType) -> Void

    init(
        title: String,
        price: String,
        badge: String? = nil,
        subscriptionType: SubscriptionType,
        onSelect: @escaping (SubscriptionType) -> Void
    ) {
        self.title = title
        self.price = price
        self.badge = badge
        self.subscriptionType = subscriptionType
        self.onSelect = onSelect
    }

    var body: some View {
        Button(action: {
            onSelect(subscriptionType)
        }) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    HStack {
                        Text(title)
                            .font(.titleMedium)
                            .foregroundColor(.brandPrimary)

                        if let badge = badge {
                            Text(badge)
                                .font(.captionSmall)
                                .foregroundColor(.white)
                                .padding(.horizontal, Spacing.sm)
                                .padding(.vertical, Spacing.xxs)
                                .background(Color.green)
                                .cornerRadius(CornerRadius.small)
                        }
                    }

                    Text(price)
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.brandPrimary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(CornerRadius.large)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Previews

#if DEBUG
struct PaywallViewPreviews: PreviewProvider {
    static var previews: some View {
        PaywallView { type in
            print("Selected: \(type)")
        }
    }
}
#endif
