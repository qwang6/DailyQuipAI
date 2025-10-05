//
//  EmptyStateView.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

/// Empty state view for when there's no content
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.textTertiary)

            VStack(spacing: Spacing.xs) {
                Text(title)
                    .titleMedium()

                Text(message)
                    .bodyMedium()
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(title: actionTitle, action: action)
                    .frame(maxWidth: 200)
            }
        }
        .paddingLarge()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Loading View

/// Loading indicator view
struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .scaleEffect(1.2)

            Text(message)
                .bodyMedium()
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Error View

/// Error state view
struct ErrorView: View {
    let error: Error
    let retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundColor(.error)

            VStack(spacing: Spacing.xs) {
                Text("Oops!")
                    .titleMedium()

                Text(error.localizedDescription)
                    .bodyMedium()
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let retryAction = retryAction {
                PrimaryButton(title: "Try Again", action: retryAction)
                    .frame(maxWidth: 200)
            }
        }
        .paddingLarge()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Previews
#if DEBUG
struct EmptyStateViewPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            EmptyStateView(
                icon: "book.fill",
                title: "No Saved Cards",
                message: "Save your favorite knowledge cards to review them later.",
                actionTitle: "Explore Cards",
                action: {}
            )

            LoadingView(message: "Loading your cards...")

            ErrorView(
                error: NetworkError.networkUnavailable,
                retryAction: {}
            )
        }
    }
}
#endif
