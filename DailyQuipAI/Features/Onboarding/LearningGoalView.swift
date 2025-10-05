//
//  LearningGoalView.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

/// Learning goal selection for daily cards
struct LearningGoalView: View {
    @Binding var dailyGoal: Int
    let onContinue: () -> Void

    private let goalOptions = [3, 5, 10, 15]

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Header
            VStack(spacing: Spacing.xs) {
                Text("Set Your Daily Goal")
                    .font(.displayMedium)
                    .foregroundColor(.textPrimary)

                Text("How many cards would you like to learn each day?")
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }
            .paddingVertical()

            Spacer()

            // Goal visualization
            VStack(spacing: Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(LinearGradient.brand)
                        .frame(width: 120, height: 120)

                    VStack(spacing: Spacing.xxs) {
                        Text("\(dailyGoal)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)

                        Text("cards/day")
                            .font(.labelMedium)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }

                Text("≈ \(estimatedTime) minutes per day")
                    .font(.bodySmall)
                    .foregroundColor(.textTertiary)
            }

            Spacer()

            // Goal options
            VStack(spacing: Spacing.md) {
                ForEach(goalOptions, id: \.self) { goal in
                    GoalOptionButton(
                        goal: goal,
                        isSelected: dailyGoal == goal
                    ) {
                        dailyGoal = goal
                        HapticFeedback.light()
                    }
                }
            }
            .padding(.horizontal, Spacing.xl)

            Spacer()

            // Continue button
            PrimaryButton(title: "Continue", action: onContinue)
                .padding(.horizontal, Spacing.xl)
                .paddingVertical()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary)
    }

    private var estimatedTime: Int {
        dailyGoal * 2 // Assuming 2 minutes per card
    }
}

// MARK: - Goal Option Button

struct GoalOptionButton: View {
    let goal: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("\(goal) cards")
                        .font(.labelLarge)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)

                    Text(difficulty)
                        .font(.captionLarge)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(LinearGradient.brand)
                }
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(Color.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .stroke(
                                isSelected ? Color.brandPrimary : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var difficulty: String {
        switch goal {
        case 3:
            return "Light - Perfect for beginners"
        case 5:
            return "Moderate - Recommended for most"
        case 10:
            return "Challenging - For dedicated learners"
        case 15:
            return "Intensive - Maximum growth"
        default:
            return ""
        }
    }
}

// MARK: - Previews
#if DEBUG
struct LearningGoalViewPreviews: PreviewProvider {
    static var previews: some View {
        LearningGoalView(
            dailyGoal: .constant(10),
            onContinue: {}
        )
    }
}
#endif
