//
//  KnowledgeCardView.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

/// Main knowledge card component with flip animation and swipe gestures
struct KnowledgeCardView: View {
    let card: Card
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void
    let onSwipeUp: () -> Void
    let onSwipeDown: () -> Void
    let onSwipeBack: (() -> Void)?  // Optional: swipe back to previous card

    @State private var isFlipped = false
    @State private var rotation: Double = 0
    @State private var offset = CGSize.zero
    @State private var dragAmount = CGSize.zero

    private let swipeThreshold: CGFloat = 100

    // Reset card state when card changes
    private var cardID: UUID {
        card.id
    }

    var body: some View {
        ZStack {
            // Back side (content)
            CardBackView(card: card)
                .rotation3DEffect(
                    .degrees(rotation + 180),
                    axis: (x: 0, y: 1, z: 0)
                )
                .opacity(isFlipped ? 1 : 0)

            // Front side (image)
            CardFrontView(card: card)
                .rotation3DEffect(
                    .degrees(rotation),
                    axis: (x: 0, y: 1, z: 0)
                )
                .opacity(isFlipped ? 0 : 1)
        }
        .offset(offset)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isFlipped.toggle()
                rotation += 180
            }
            HapticFeedback.light()
        }
        .gesture(
            DragGesture(minimumDistance: 20)  // Changed from 0 to 20 to allow tap gestures
                .onChanged { gesture in
                    dragAmount = gesture.translation
                    offset = gesture.translation
                }
                .onEnded { gesture in
                    handleSwipeGesture(gesture.translation)
                }
        )
        .onLongPressGesture(minimumDuration: 0.5) {
            HapticFeedback.medium()
            // Show quick action menu (future implementation)
        }
        .id(cardID)  // Force view reset when card changes
        .onChange(of: cardID) {
            // Reset state for new card
            isFlipped = false
            rotation = 0
            offset = .zero
            dragAmount = .zero
        }
        .onAppear {
            print("🎴 Card appeared - ID: \(cardID)")
            print("   - isFlipped: \(isFlipped)")
            print("   - offset: \(offset)")
            // Always reset state when card appears
            isFlipped = false
            rotation = 0
            offset = .zero
            dragAmount = .zero
        }
        #if targetEnvironment(simulator)
        // Keyboard shortcuts for simulator testing
        .onKeyPress(.upArrow) {
            withAnimation(.spring()) {
                offset = CGSize(width: 0, height: -500)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onSwipeUp()
            }
            return .handled
        }
        .onKeyPress(.downArrow) {
            withAnimation(.spring()) {
                offset = CGSize(width: 0, height: 500)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onSwipeDown()
            }
            return .handled
        }
        .onKeyPress(.leftArrow) {
            withAnimation(.spring()) {
                offset = CGSize(width: -500, height: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onSwipeLeft()
            }
            return .handled
        }
        .onKeyPress(.rightArrow) {
            withAnimation(.spring()) {
                offset = CGSize(width: 500, height: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onSwipeRight()
            }
            return .handled
        }
        .onKeyPress(.space) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isFlipped.toggle()
                rotation += 180
            }
            HapticFeedback.light()
            return .handled
        }
        #endif
    }

    private func handleSwipeGesture(_ translation: CGSize) {
        let horizontalSwipe = abs(translation.width) > abs(translation.height)
        let verticalSwipe = abs(translation.height) > abs(translation.width)

        if horizontalSwipe && abs(translation.width) > swipeThreshold {
            // Left or right swipe
            if translation.width > 0 {
                // Right swipe - Save
                withAnimation(.easeOut(duration: 0.3)) {
                    offset = CGSize(width: 500, height: 0)
                }
                HapticFeedback.success()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onSwipeRight()
                    // Reset offset immediately after callback
                    self.resetCardState()
                }
            } else {
                // Left swipe - Learned
                withAnimation(.easeOut(duration: 0.3)) {
                    offset = CGSize(width: -500, height: 0)
                }
                HapticFeedback.light()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onSwipeLeft()
                    // Reset offset immediately after callback
                    self.resetCardState()
                }
            }
        } else if verticalSwipe && abs(translation.height) > swipeThreshold {
            // Up or down swipe - both go to next card
            if translation.height < 0 {
                // Up swipe - Next card
                withAnimation(.easeOut(duration: 0.3)) {
                    offset = CGSize(width: 0, height: -500)
                }
                HapticFeedback.light()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onSwipeUp()
                    // Reset offset immediately after callback
                    self.resetCardState()
                }
            } else {
                // Down swipe - Next card
                withAnimation(.easeOut(duration: 0.3)) {
                    offset = CGSize(width: 0, height: 500)
                }
                HapticFeedback.light()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onSwipeDown()
                    // Reset offset immediately after callback
                    self.resetCardState()
                }
            }
        } else {
            // Reset if swipe not strong enough
            withAnimation(.spring()) {
                offset = .zero
                dragAmount = .zero
            }
        }
    }

    private func resetCardState() {
        offset = .zero
        dragAmount = .zero
        isFlipped = false
        rotation = 0
    }
}

// MARK: - Card Front View

struct CardFrontView: View {
    let card: Card

    var body: some View {
        ZStack(alignment: .topLeading) {
            // All background layers in a single clipped group
            ZStack {
                // Vibrant gradient base
                card.category.glassGradient
                    .opacity(0.75)

                // Glass material (lighter for more color)
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.6)

                // Enhanced color overlay
                LinearGradient(
                    colors: [
                        card.category.accentColor.opacity(0.4),
                        card.category.color.opacity(0.35),
                        card.category.accentColor.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Bright top highlight
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.4),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .center
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: DeviceSize.cardCornerRadius, style: .continuous))

            // Content overlay
            VStack(alignment: .leading, spacing: Spacing.sm) {
                // Glass category tag
                HStack(spacing: Spacing.xs) {
                    Image(systemName: card.category.icon)
                        .font(.system(size: DeviceSize.categoryTagSize, weight: .semibold))
                    Text(card.category.rawValue)
                        .font(.system(size: DeviceSize.categoryTagSize, weight: .semibold))
                }
                .foregroundStyle(Color.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)

                Spacer()

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(card.title)
                        .font(.system(size: DeviceSize.cardTitleSize, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color.white.opacity(0.95)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .lineLimit(3)
                        .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 4)

                    HStack(spacing: 4) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 11))
                        Text("Tap to flip")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.25))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                            )
                    )
                }
            }
            .paddingStandard()
        }
        .clipShape(RoundedRectangle(cornerRadius: DeviceSize.cardCornerRadius, style: .continuous))
        .overlay(
            // Vibrant border
            RoundedRectangle(cornerRadius: DeviceSize.cardCornerRadius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.7),
                            card.category.accentColor.opacity(0.5),
                            Color.white.opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        // Colorful shadow
        .shadow(color: card.category.color.opacity(0.4), radius: 25, x: 0, y: 12)
        .shadow(color: .black.opacity(0.2), radius: 40, x: 0, y: 20)
    }
}

// MARK: - Card Back View

struct CardBackView: View {
    let card: Card

    var body: some View {
        ZStack {
            // All background layers in a single clipped group
            ZStack {
                // Rich gradient
                card.category.glassGradient
                    .opacity(0.7)

                // Light glass material
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.65)

                // Color enhancement
                LinearGradient(
                    colors: [
                        card.category.color.opacity(0.35),
                        card.category.accentColor.opacity(0.4)
                    ],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )

                // Bright highlight
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.35),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .center
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: DeviceSize.cardCornerRadius, style: .continuous))

            // Content
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Header with glass effect
                HStack {
                    // Glass category tag
                    HStack(spacing: 6) {
                        Image(systemName: card.category.icon)
                            .font(.system(size: 12, weight: .semibold))
                        Text(card.category.rawValue)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(card.category.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(.thinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(card.category.color.opacity(0.3), lineWidth: 1)
                            )
                    )

                    Spacer()

                    Text(card.readTimeFormatted)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary.opacity(0.7))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(.thinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                                )
                        )
                }

                // Title
                Text(card.title)
                    .font(.system(size: DeviceSize.isIPad ? 28 : 22, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.primary,
                                Color.primary.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .lineLimit(2)

                // Divider with glass effect
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                card.category.color.opacity(0.4),
                                card.category.color.opacity(0.1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)

                // Content with glass background
                ScrollView {
                    EnhancedMarkdownText(
                        card.backContent,
                        fontSize: DeviceSize.cardBodySize,
                        lineSpacing: 6
                    )
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                    )
                }

                Spacer()

                // Footer with glass tags
                HStack {
                    Text("Source: \(card.source)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.primary.opacity(0.6))

                    Spacer()

                    // Tags with glass effect
                    ForEach(card.tags.prefix(2), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(card.category.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(.thinMaterial)
                                    .overlay(
                                        Capsule()
                                            .stroke(card.category.color.opacity(0.25), lineWidth: 0.5)
                                    )
                            )
                    }
                }
            }
            .paddingStandard()
        }
        .clipShape(RoundedRectangle(cornerRadius: DeviceSize.cardCornerRadius, style: .continuous))
        .overlay(
            // Colorful border
            RoundedRectangle(cornerRadius: DeviceSize.cardCornerRadius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.65),
                            card.category.accentColor.opacity(0.55),
                            Color.white.opacity(0.35)
                        ],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: card.category.color.opacity(0.35), radius: 22, x: 0, y: 10)
        .shadow(color: .black.opacity(0.18), radius: 38, x: 0, y: 18)
    }
}

// MARK: - Haptic Feedback

struct HapticFeedback {
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

// MARK: - Previews
#if DEBUG
struct KnowledgeCardViewPreviews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.xl) {
            KnowledgeCardView(
                card: Card.mock(),
                onSwipeLeft: { print("Learned") },
                onSwipeRight: { print("Saved") },
                onSwipeUp: { print("Share") },
                onSwipeDown: { print("Details") },
                onSwipeBack: { print("Back") }
            )
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
