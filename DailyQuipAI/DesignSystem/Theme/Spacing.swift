//
//  Spacing.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

/// Spacing system based on 4pt grid
enum Spacing {
    /// 4pt
    static let xxs: CGFloat = 4

    /// 8pt
    static let xs: CGFloat = 8

    /// 12pt
    static let sm: CGFloat = 12

    /// 16pt (base unit)
    static let md: CGFloat = 16

    /// 20pt
    static let lg: CGFloat = 20

    /// 24pt
    static let xl: CGFloat = 24

    /// 32pt
    static let xxl: CGFloat = 32

    /// 40pt
    static let xxxl: CGFloat = 40

    /// 48pt
    static let huge: CGFloat = 48

    /// 64pt
    static let massive: CGFloat = 64
}

// MARK: - Corner Radius

enum CornerRadius {
    /// 4pt - Small elements
    static let small: CGFloat = 4

    /// 8pt - Buttons, inputs
    static let medium: CGFloat = 8

    /// 12pt - Cards, panels
    static let large: CGFloat = 12

    /// 20pt - Large cards (as per PRD)
    static let xlarge: CGFloat = 20

    /// 28pt - Extra large
    static let xxlarge: CGFloat = 28

    /// Full circle
    static let full: CGFloat = 999
}

// MARK: - Padding Modifiers

extension View {
    /// Apply standard padding (16pt)
    func paddingStandard() -> some View {
        self.padding(Spacing.md)
    }

    /// Apply horizontal standard padding
    func paddingHorizontal() -> some View {
        self.padding(.horizontal, Spacing.md)
    }

    /// Apply vertical standard padding
    func paddingVertical() -> some View {
        self.padding(.vertical, Spacing.md)
    }

    /// Apply small padding (8pt)
    func paddingSmall() -> some View {
        self.padding(Spacing.xs)
    }

    /// Apply large padding (24pt)
    func paddingLarge() -> some View {
        self.padding(Spacing.xl)
    }
}

// MARK: - Shadow Styles

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension ShadowStyle {
    /// Subtle shadow for cards
    static let card = ShadowStyle(
        color: .shadow,
        radius: 8,
        x: 0,
        y: 2
    )

    /// Medium shadow for elevated elements
    static let elevated = ShadowStyle(
        color: .shadow,
        radius: 12,
        x: 0,
        y: 4
    )

    /// Strong shadow for floating elements
    static let floating = ShadowStyle(
        color: .shadow,
        radius: 16,
        x: 0,
        y: 6
    )
}

extension View {
    /// Apply card shadow
    func cardShadow() -> some View {
        self.shadow(
            color: ShadowStyle.card.color,
            radius: ShadowStyle.card.radius,
            x: ShadowStyle.card.x,
            y: ShadowStyle.card.y
        )
    }

    /// Apply elevated shadow
    func elevatedShadow() -> some View {
        self.shadow(
            color: ShadowStyle.elevated.color,
            radius: ShadowStyle.elevated.radius,
            x: ShadowStyle.elevated.x,
            y: ShadowStyle.elevated.y
        )
    }

    /// Apply floating shadow
    func floatingShadow() -> some View {
        self.shadow(
            color: ShadowStyle.floating.color,
            radius: ShadowStyle.floating.radius,
            x: ShadowStyle.floating.x,
            y: ShadowStyle.floating.y
        )
    }
}

// MARK: - Border Styles

extension View {
    /// Apply standard border
    func standardBorder() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .stroke(Color.border, lineWidth: 1)
        )
    }

    /// Apply card border with corner radius
    func cardBorder() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: CornerRadius.xlarge)
                .stroke(Color.border, lineWidth: 1)
        )
    }
}

// MARK: - Layout Constants

enum Layout {
    /// Maximum width for readable content
    static let maxReadableWidth: CGFloat = 640

    /// Standard card aspect ratio (16:9)
    static let cardAspectRatio: CGFloat = 16 / 9

    /// Portrait card aspect ratio (1:1)
    static let portraitCardAspectRatio: CGFloat = 1

    /// Minimum touch target size (44pt)
    static let minTouchTarget: CGFloat = 44

    /// Tab bar height
    static let tabBarHeight: CGFloat = 49

    /// Navigation bar height
    static let navBarHeight: CGFloat = 44
}
