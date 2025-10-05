//
//  ShareSheet.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import SwiftUI
import UIKit

/// Share sheet wrapper for SwiftUI
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let excludedActivityTypes: [UIActivity.ActivityType]?

    init(items: [Any], excludedActivityTypes: [UIActivity.ActivityType]? = nil) {
        self.items = items
        self.excludedActivityTypes = excludedActivityTypes
    }

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        controller.excludedActivityTypes = excludedActivityTypes
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}

// MARK: - View Extension for Share

extension View {
    /// Present share sheet with items
    func shareSheet(isPresented: Binding<Bool>, items: [Any]) -> some View {
        sheet(isPresented: isPresented) {
            ShareSheet(items: items)
        }
    }
}

// MARK: - Card Share Helper

struct CardShareHelper {
    /// Create shareable items from a card
    static func createShareItems(for card: Card) -> [Any] {
        var items: [Any] = []

        // Share text
        let shareText = """
        📚 \(card.title)

        \(card.backContent)

        Category: \(card.category.rawValue)

        Learned on DailyQuipAI - Daily Knowledge Cards
        """
        items.append(shareText)

        // Note: Image sharing would require downloading the image first
        // For now, just include the URL
        items.append(card.frontImageURL)

        return items
    }

    /// Create share text with custom message
    static func createShareText(for card: Card, customMessage: String? = nil) -> String {
        var text = "📚 \(card.title)\n\n"

        if let message = customMessage {
            text += "\(message)\n\n"
        }

        text += "\(card.backContent)\n\n"
        text += "Category: \(card.category.rawValue)\n\n"
        text += "Learned on DailyQuipAI - Daily Knowledge Cards"

        return text
    }
}
