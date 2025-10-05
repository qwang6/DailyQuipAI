//
//  ContentView.swift
//  DailyQuipAI
//
//  Created by Qian Wang on 10/4/25.
//

import SwiftUI

#if DEBUG
struct ContentView: View {
    @State private var currentCardIndex = 0
    @State private var cards: [Card] = Card.mockArray(count: 3)

    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("DailyQuipAI")
                        .font(.displayMedium)
                        .foregroundColor(.brandPrimary)

                    Text("Daily Knowledge Cards")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                StreakIndicator(days: 7)
            }
            .paddingHorizontal()
            .paddingVertical()

            // Progress indicator
            if !cards.isEmpty {
                VStack(spacing: Spacing.xs) {
                    Text("Card \(currentCardIndex + 1) of \(cards.count)")
                        .font(.labelMedium)
                        .foregroundColor(.textSecondary)

                    DotProgressIndicator(total: cards.count, current: currentCardIndex)
                }
            }

            // Card
            if currentCardIndex < cards.count {
                KnowledgeCardView(
                    card: cards[currentCardIndex],
                    onSwipeLeft: {
                        print("Card learned: \(cards[currentCardIndex].title)")
                        nextCard()
                    },
                    onSwipeRight: {
                        print("Card saved: \(cards[currentCardIndex].title)")
                        nextCard()
                    },
                    onSwipeUp: {
                        print("Share card: \(cards[currentCardIndex].title)")
                    },
                    onSwipeDown: {
                        print("Show details: \(cards[currentCardIndex].title)")
                    },
                    onSwipeBack: nil
                )
                .padding(.horizontal, Spacing.xl)
            } else {
                // All cards completed
                EmptyStateView(
                    icon: "checkmark.circle.fill",
                    title: "All Done!",
                    message: "You've completed today's knowledge cards. Great job!",
                    actionTitle: "Review Cards",
                    action: {
                        // Reset for demo
                        currentCardIndex = 0
                        cards = Card.mockArray(count: 3)
                    }
                )
            }

            Spacer()

            // Instructions
            if currentCardIndex < cards.count {
                VStack(spacing: Spacing.xs) {
                    Text("Swipe Instructions")
                        .font(.labelMedium)
                        .foregroundColor(.textSecondary)

                    HStack(spacing: Spacing.xl) {
                        HStack(spacing: Spacing.xxs) {
                            Image(systemName: "arrow.left")
                            Text("Learn")
                        }
                        .font(.captionLarge)
                        .foregroundColor(.textTertiary)

                        HStack(spacing: Spacing.xxs) {
                            Image(systemName: "arrow.right")
                            Text("Save")
                        }
                        .font(.captionLarge)
                        .foregroundColor(.textTertiary)

                        HStack(spacing: Spacing.xxs) {
                            Image(systemName: "arrow.up")
                            Text("Share")
                        }
                        .font(.captionLarge)
                        .foregroundColor(.textTertiary)
                    }
                }
                .paddingVertical()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary)
    }

    private func nextCard() {
        withAnimation(.spring()) {
            currentCardIndex += 1
        }
    }
}

#Preview {
    ContentView()
}
#endif
