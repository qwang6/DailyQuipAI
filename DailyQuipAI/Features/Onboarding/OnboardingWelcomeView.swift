//
//  OnboardingWelcomeView.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

/// Welcome screen for onboarding flow
struct OnboardingWelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()

            // App icon and branding
            VStack(spacing: Spacing.lg) {
                Image(systemName: "sparkles")
                    .font(.system(size: 80))
                    .foregroundStyle(LinearGradient.brand)

                VStack(spacing: Spacing.xs) {
                    Text("onboarding.welcome.title".localized)
                        .font(.displayLarge)
                        .foregroundColor(.textPrimary)

                    Text("onboarding.welcome.subtitle".localized)
                        .font(.bodyLarge)
                        .foregroundColor(.textSecondary)
                }
            }

            Spacer()

            // Features list
            VStack(alignment: .leading, spacing: Spacing.md) {
                OnboardingFeatureRow(
                    icon: "book.fill",
                    title: "onboarding.feature.learnDaily.title".localized,
                    description: "onboarding.feature.learnDaily.description".localized
                )

                OnboardingFeatureRow(
                    icon: "brain.head.profile",
                    title: "onboarding.feature.testYourself.title".localized,
                    description: "onboarding.feature.testYourself.description".localized
                )

                OnboardingFeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "onboarding.feature.trackProgress.title".localized,
                    description: "onboarding.feature.trackProgress.description".localized
                )
            }
            .padding(.horizontal, Spacing.xl)

            Spacer()

            // CTA button
            PrimaryButton(title: "onboarding.welcome.getStarted".localized, action: onContinue)
                .padding(.horizontal, Spacing.xl)
                .paddingVertical()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary)
    }
}

// MARK: - Feature Row Component

struct OnboardingFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(LinearGradient.brand)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(title)
                    .font(.labelLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)

                Text(description)
                    .font(.bodySmall)
                    .foregroundColor(.textSecondary)
            }

            Spacer()
        }
    }
}

// MARK: - Previews
#if DEBUG
struct OnboardingWelcomeViewPreviews: PreviewProvider {
    static var previews: some View {
        OnboardingWelcomeView(onContinue: {})
    }
}
#endif
