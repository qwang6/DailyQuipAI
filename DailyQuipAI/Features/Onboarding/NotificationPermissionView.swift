//
//  NotificationPermissionView.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import SwiftUI
import UserNotifications

/// Notification permission request screen
struct NotificationPermissionView: View {
    let onContinue: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // Icon
            VStack(spacing: Spacing.lg) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(LinearGradient.brand)

                VStack(spacing: Spacing.xs) {
                    Text("Stay on Track")
                        .font(.displayMedium)
                        .foregroundColor(.textPrimary)

                    Text("Get daily reminders to keep your learning streak alive")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)
                }
            }

            Spacer()

            // Benefits
            VStack(alignment: .leading, spacing: Spacing.md) {
                NotificationBenefit(
                    icon: "clock.fill",
                    text: "Daily reminders at your preferred time"
                )

                NotificationBenefit(
                    icon: "flame.fill",
                    text: "Streak alerts to maintain momentum"
                )

                NotificationBenefit(
                    icon: "trophy.fill",
                    text: "Achievement notifications"
                )
            }
            .padding(.horizontal, Spacing.xl)

            Spacer()

            // Action buttons
            VStack(spacing: Spacing.md) {
                PrimaryButton(title: "Enable Notifications") {
                    requestNotificationPermission()
                }

                TextButton(title: "Maybe Later", action: onSkip)
            }
            .padding(.horizontal, Spacing.xl)
            .paddingVertical()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary)
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    HapticFeedback.success()
                } else {
                    HapticFeedback.light()
                }
                onContinue()
            }
        }
    }
}

// MARK: - Notification Benefit Row

struct NotificationBenefit: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(LinearGradient.brand)
                .frame(width: 32, height: 32)

            Text(text)
                .font(.bodyMedium)
                .foregroundColor(.textPrimary)

            Spacer()
        }
    }
}

// MARK: - Previews
#if DEBUG
struct NotificationPermissionViewPreviews: PreviewProvider {
    static var previews: some View {
        NotificationPermissionView(
            onContinue: {},
            onSkip: {}
        )
    }
}
#endif
