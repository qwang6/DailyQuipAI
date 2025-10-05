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

/// Loading indicator view with rotating tips
struct LoadingView: View {
    var message: String = "Loading..."
    @StateObject private var tipsManager: LoadingTipsManager

    // Simple initializer for static message
    init(message: String = "Loading...") {
        self.message = message
        // Create a simple tips generator with hardcoded tips
        let generator = LoadingTipsGenerator(
            llmGenerator: LLMCardGenerator(apiKey: "", provider: .gemini)
        )
        _tipsManager = StateObject(wrappedValue: LoadingTipsManager(tipsGenerator: generator))
    }

    // Advanced initializer with tips rotation
    init(withRotatingTips: Bool = false, llmGenerator: LLMCardGenerator? = nil) {
        self.message = "Loading..."

        if withRotatingTips, let generator = llmGenerator {
            let tipsGen = LoadingTipsGenerator(llmGenerator: generator)
            _tipsManager = StateObject(wrappedValue: LoadingTipsManager(tipsGenerator: tipsGen))
        } else {
            let tipsGen = LoadingTipsGenerator(
                llmGenerator: LLMCardGenerator(apiKey: "", provider: .gemini)
            )
            _tipsManager = StateObject(wrappedValue: LoadingTipsManager(tipsGenerator: tipsGen))
        }
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .scaleEffect(1.2)

            Text(tipsManager.currentTip.isEmpty ? message : tipsManager.currentTip)
                .bodyMedium()
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
                .transition(.opacity)
                .id(tipsManager.currentTip) // Force view update on tip change
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // Start rotating tips when view appears (non-blocking)
            tipsManager.startRotatingTips()
        }
        .onDisappear {
            // Stop rotating when view disappears
            tipsManager.stopRotatingTips()
        }
    }
}

/// Simple loading view without rotating tips
struct SimpleLoadingView: View {
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
