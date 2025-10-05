//
//  Buttons.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

/// Primary button style
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }

                Text(title)
                    .font(.labelLarge)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: Layout.minTouchTarget)
            .background(isDisabled ? Color.gray : Color.brandPrimary)
            .foregroundColor(.white)
            .cornerRadius(CornerRadius.medium)
        }
        .disabled(isDisabled || isLoading)
    }
}

/// Secondary button style (outlined)
struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.labelLarge)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .frame(height: Layout.minTouchTarget)
                .foregroundColor(isDisabled ? .gray : .brandPrimary)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.medium)
                        .stroke(isDisabled ? Color.gray : Color.brandPrimary, lineWidth: 2)
                )
        }
        .disabled(isDisabled)
    }
}

/// Text button (no background)
struct TextButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.labelLarge)
                .fontWeight(.medium)
                .foregroundColor(isDisabled ? .gray : .brandPrimary)
        }
        .disabled(isDisabled)
    }
}

/// Icon button
struct IconButton: View {
    let icon: String
    let action: () -> Void
    var size: CGFloat = 24
    var tint: Color = .textPrimary

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size))
                .foregroundColor(tint)
                .frame(width: Layout.minTouchTarget, height: Layout.minTouchTarget)
        }
    }
}

// MARK: - Previews
#if DEBUG
struct ButtonPreviews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.md) {
            PrimaryButton(title: "Primary Button", action: {})

            PrimaryButton(title: "Loading", action: {}, isLoading: true)

            PrimaryButton(title: "Disabled", action: {}, isDisabled: true)

            SecondaryButton(title: "Secondary Button", action: {})

            TextButton(title: "Text Button", action: {})

            IconButton(icon: "heart.fill", action: {})
        }
        .paddingStandard()
        .previewLayout(.sizeThatFits)
    }
}
#endif
