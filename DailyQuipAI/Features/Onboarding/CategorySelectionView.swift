//
//  CategorySelectionView.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

/// Category selection screen for onboarding
struct CategorySelectionView: View {
    @Binding var selectedCategories: Set<Category>
    let onContinue: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Header
            VStack(spacing: Spacing.xs) {
                Text("onboarding.categories.title".localized)
                    .font(.displayMedium)
                    .foregroundColor(.textPrimary)

                Text("onboarding.categories.subtitle".localized)
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .paddingVertical()

            // Category grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: Spacing.md) {
                    ForEach(Category.allCases) { category in
                        CategorySelectionCard(
                            category: category,
                            isSelected: selectedCategories.contains(category)
                        ) {
                            toggleCategory(category)
                        }
                    }
                }
                .padding(.horizontal, Spacing.xl)
            }

            Spacer()

            // Selection info and continue button
            VStack(spacing: Spacing.md) {
                Text(selectedCategories.isEmpty
                    ? "onboarding.categories.selectAtLeastOne".localized
                    : String(format: "onboarding.categories.selectedCount".localized, selectedCategories.count))
                    .font(.bodySmall)
                    .foregroundColor(.textSecondary)

                PrimaryButton(
                    title: "onboarding.categories.continue".localized,
                    action: onContinue
                )
                .disabled(selectedCategories.isEmpty)
                .opacity(selectedCategories.isEmpty ? 0.5 : 1.0)
                .padding(.horizontal, Spacing.xl)
            }
            .paddingVertical()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary)
    }

    private func toggleCategory(_ category: Category) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
        HapticFeedback.light()
    }
}

// MARK: - Category Selection Card

struct CategorySelectionCard: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            isSelected
                                ? LinearGradient.category(category)
                                : LinearGradient(colors: [Color.backgroundSecondary], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 64, height: 64)

                    Image(systemName: category.icon)
                        .font(.system(size: 28))
                        .foregroundColor(isSelected ? .white : category.color)
                }

                // Label
                Text(category.displayName)
                    .font(.labelMedium)
                    .foregroundColor(.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.large)
                    .fill(Color.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.large)
                            .stroke(
                                isSelected ? category.color : Color.clear,
                                lineWidth: isSelected ? 2 : 0
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Previews
#if DEBUG
struct CategorySelectionViewPreviews: PreviewProvider {
    @State static var selectedCategories: Set<Category> = [.science, .history]

    static var previews: some View {
        CategorySelectionView(
            selectedCategories: .constant([.science, .history]),
            onContinue: {}
        )
    }
}
#endif
