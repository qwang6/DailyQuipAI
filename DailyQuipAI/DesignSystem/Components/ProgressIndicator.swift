//
//  ProgressIndicator.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

/// Progress indicator showing current position in a set (e.g., 1/3, 2/3, 3/3)
struct DotProgressIndicator: View {
    let total: Int
    let current: Int

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index == current ? Color.brandPrimary : Color.textTertiary.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == current ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3), value: current)
            }
        }
        .padding(.vertical, Spacing.xs)
    }
}

/// Linear progress bar
struct LinearProgressBar: View {
    let progress: Double // 0.0 to 1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .fill(Color.textTertiary.opacity(0.2))
                    .frame(height: 4)
                    .cornerRadius(2)

                // Progress
                Rectangle()
                    .fill(Color.brandPrimary)
                    .frame(width: geometry.size.width * min(max(progress, 0), 1), height: 4)
                    .cornerRadius(2)
                    .animation(.spring(), value: progress)
            }
        }
        .frame(height: 4)
    }
}

/// Circular progress indicator
struct CircularProgressView: View {
    let progress: Double // 0.0 to 1.0
    var lineWidth: CGFloat = 8
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.textTertiary.opacity(0.2), lineWidth: lineWidth)

            // Progress circle
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    LinearGradient.brand,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(), value: progress)

            // Percentage text
            Text("\(Int(progress * 100))%")
                .font(.labelLarge)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
        }
        .frame(width: size, height: size)
    }
}

/// Streak flame indicator
struct StreakIndicator: View {
    let days: Int
    var size: CGFloat = 24

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: "flame.fill")
                .font(.system(size: size))
                .foregroundColor(flameColor)

            Text("\(days)")
                .font(.labelLarge)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
        }
    }

    private var flameColor: Color {
        switch days {
        case 0...6:
            return .gray
        case 7...29:
            return .warning
        case 30...99:
            return Color(hex: "FF6B35")
        default:
            return Color(hex: "FF4500")
        }
    }
}

// MARK: - Previews
#if DEBUG
struct ProgressIndicatorPreviews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.xl) {
            DotProgressIndicator(total: 5, current: 2)

            LinearProgressBar(progress: 0.65)
                .frame(height: 4)
                .padding(.horizontal)

            CircularProgressView(progress: 0.75)

            StreakIndicator(days: 7)
            StreakIndicator(days: 30)
            StreakIndicator(days: 100)
        }
        .paddingStandard()
        .previewLayout(.sizeThatFits)
    }
}
#endif
