//
//  DailyCardsView.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

/// Main daily cards view with state management
struct DailyCardsView: View {
    @StateObject private var viewModel = DailyCardsViewModel()
    @State private var showSettings = false
    @State private var showCategoryPicker = false

    var body: some View {
        VStack(spacing: 0) {
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

                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.md)
            .background(Color.backgroundPrimary)

            // Category filter
            CategoryFilterBar(
                selectedCategory: viewModel.selectedCategory,
                onSelectCategory: { category in
                    Task {
                        await viewModel.switchCategory(category)
                    }
                }
            )
            .padding(.bottom, Spacing.sm)

            // Content - using GeometryReader to properly size the card area
            GeometryReader { geometry in
                if viewModel.isLoading {
                    LoadingView(message: "Loading today's cards...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.showError, let error = viewModel.error {
                    ErrorView(error: error) {
                        Task {
                            await viewModel.retry()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.hasMoreCards, let card = viewModel.currentCard {
                    VStack(spacing: Spacing.md) {
                        // Progress indicator
                        VStack(spacing: Spacing.xs) {
                            Text("Card \(viewModel.currentCardIndex + 1) of \(viewModel.totalCards)")
                                .font(.labelMedium)
                                .foregroundColor(.textSecondary)

                            DotProgressIndicator(
                                total: viewModel.totalCards,
                                current: viewModel.currentCardIndex
                            )
                        }

                        // Card
                        KnowledgeCardView(
                            card: card,
                            onSwipeLeft: {
                                Task {
                                    await viewModel.markAsLearned()
                                }
                            },
                            onSwipeRight: {
                                Task {
                                    await viewModel.saveCard()
                                }
                            },
                            onSwipeUp: {
                                // Up swipe - next card
                                viewModel.moveToNextCard()
                            },
                            onSwipeDown: {
                                // Down swipe - previous card
                                viewModel.moveToPreviousCard()
                            },
                            onSwipeBack: nil  // Not using double-tap anymore
                        )
                        .frame(
                            width: DeviceSize.cardWidth(for: geometry),
                            height: DeviceSize.cardHeight(for: geometry)
                        )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.lg)
                } else {
                    // No cards available or all cards completed
                    if viewModel.cards.isEmpty && viewModel.selectedCategory != nil {
                        // Free user selected a category with no cards
                        EmptyStateView(
                            icon: "sparkles",
                            title: "No Cards in This Category",
                            message: "Switch to 'All' to see your available cards, or upgrade to Premium for unlimited access to all categories.",
                            actionTitle: "Upgrade to Premium",
                            action: {
                                viewModel.showPaywall = true
                            }
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // All cards completed
                        EmptyStateView(
                            icon: "checkmark.circle.fill",
                            title: "All Done!",
                            message: "You've completed today's knowledge cards. Great job!",
                            actionTitle: "Review Saved Cards",
                            action: {
                                // Navigate to saved cards
                            }
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary.ignoresSafeArea())
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $viewModel.showPaywall) {
            PaywallView(
                onUpgrade: { subscriptionType in
                    print("💳 Paywall - User selected: \(subscriptionType.rawValue)")
                    // Handle subscription upgrade
                    SubscriptionManager.shared.updateSubscription(to: subscriptionType)
                    viewModel.showPaywall = false
                    print("✅ Paywall dismissed after upgrade")
                },
                onDismiss: {
                    print("❌ Paywall - User dismissed without upgrading")
                    // User dismissed without upgrading - keep them on current card
                    viewModel.showPaywall = false
                    print("📍 Current card index after dismiss: \(viewModel.currentCardIndex)")
                    print("📚 Total cards available: \(viewModel.cards.count)")
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled(false)
        }
        .onChange(of: viewModel.showPaywall) {
            print("🎬 Paywall state changed to: \(viewModel.showPaywall)")
        }
        .task {
            await viewModel.fetchDailyCards()
        }
    }
}

// MARK: - Category Filter Bar

struct CategoryFilterBar: View {
    let selectedCategory: Category?
    let onSelectCategory: (Category?) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                // Category buttons
                ForEach(Category.allCases) { category in
                    CategoryFilterChip(
                        title: category.rawValue,
                        icon: category.icon,
                        category: category,
                        isSelected: selectedCategory == category,
                        action: { onSelectCategory(category) }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryFilterChip: View {
    let title: String
    let icon: String
    let category: Category?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xxs) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Group {
                    if isSelected {
                        if let category = category {
                            // Use category's glass gradient
                            ZStack {
                                category.glassGradient
                                Rectangle()
                                    .fill(.ultraThinMaterial)
                                    .opacity(0.3)
                            }
                        } else {
                            // "All" button - use brand gradient
                            LinearGradient(
                                colors: [
                                    Color.brandPrimary.opacity(0.9),
                                    Color.brandPrimary.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    } else {
                        Color.backgroundSecondary
                    }
                }
            )
            .foregroundColor(isSelected ? .white : .textSecondary)
            .cornerRadius(CornerRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.large)
                    .stroke(
                        isSelected ?
                            (category != nil ? category!.accentColor.opacity(0.5) : Color.white.opacity(0.3))
                            : Color.clear,
                        lineWidth: isSelected ? 1 : 0
                    )
            )
            .shadow(
                color: isSelected ?
                    (category != nil ? category!.color.opacity(0.3) : Color.brandPrimary.opacity(0.3))
                    : Color.clear,
                radius: isSelected ? 8 : 0,
                x: 0,
                y: isSelected ? 4 : 0
            )
        }
    }
}

// MARK: - Swipe Instructions Component

struct SwipeInstructions: View {
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text("Swipe Instructions")
                .font(.labelMedium)
                .foregroundColor(.textSecondary)

            HStack(spacing: Spacing.xl) {
                SwipeInstruction(icon: "arrow.left", label: "Learn")
                SwipeInstruction(icon: "arrow.right", label: "Save")
                SwipeInstruction(icon: "arrow.up", label: "Next")
            }
        }
        .paddingVertical()
    }
}

struct SwipeInstruction: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: icon)
            Text(label)
        }
        .font(.captionLarge)
        .foregroundColor(.textTertiary)
    }
}

// MARK: - Previews
#if DEBUG
struct DailyCardsViewPreviews: PreviewProvider {
    static var previews: some View {
        DailyCardsView()
    }
}
#endif
