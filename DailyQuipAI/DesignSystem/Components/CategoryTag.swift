//
//  CategoryTag.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

/// Category tag component
struct CategoryTag: View {
    let category: Category
    var size: TagSize = .medium

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: category.icon)
                .font(.system(size: size.iconSize))

            Text(category.rawValue)
                .font(size.font)
        }
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .background(category.color.opacity(0.15))
        .foregroundColor(category.color)
        .cornerRadius(CornerRadius.small)
    }

    enum TagSize {
        case small
        case medium
        case large

        var font: Font {
            switch self {
            case .small: return .captionSmall
            case .medium: return .labelMedium
            case .large: return .labelLarge
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 12
            case .large: return 14
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return Spacing.xs
            case .medium: return Spacing.sm
            case .large: return Spacing.md
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .small: return Spacing.xxs
            case .medium: return Spacing.xs
            case .large: return Spacing.sm
            }
        }
    }
}

// MARK: - Difficulty Tag

/// Difficulty indicator tag
struct DifficultyTag: View {
    let difficulty: Int // 1-5

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                Image(systemName: index < difficulty ? "star.fill" : "star")
                    .font(.system(size: 10))
                    .foregroundColor(index < difficulty ? .warning : .textTertiary)
            }
        }
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, Spacing.xxs)
        .background(Color.backgroundSecondary)
        .cornerRadius(CornerRadius.small)
    }
}

// MARK: - Previews
#if DEBUG
struct CategoryTagPreviews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.md) {
            CategoryTag(category: .history, size: .small)
            CategoryTag(category: .science, size: .medium)
            CategoryTag(category: .art, size: .large)

            DifficultyTag(difficulty: 3)
            DifficultyTag(difficulty: 5)
        }
        .paddingStandard()
        .previewLayout(.sizeThatFits)
    }
}
#endif
