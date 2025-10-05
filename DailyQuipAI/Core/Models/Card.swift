//
//  Card.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import Foundation

/// A knowledge card containing a learning nugget
struct Card: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let category: Category
    let frontImageURL: URL
    let backContent: String
    let tags: [String]
    let source: String
    let difficulty: Int // 1-5 stars
    let estimatedReadTime: Int // in seconds
    let createdAt: Date

    // Computed property for display
    var difficultyStars: String {
        String(repeating: "⭐", count: min(max(difficulty, 1), 5))
    }

    var readTimeFormatted: String {
        let minutes = estimatedReadTime / 60
        let seconds = estimatedReadTime % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s read"
        } else {
            return "\(seconds)s read"
        }
    }
}

// MARK: - Mock Data for Testing
#if DEBUG
extension Card {
    /// Create a single mock card for testing
    static func mock(
        id: UUID = UUID(),
        title: String = "The Renaissance Revolution",
        category: Category = .history,
        difficulty: Int = 3
    ) -> Card {
        Card(
            id: id,
            title: title,
            category: category,
            frontImageURL: URL(string: "https://picsum.photos/400/600")!,
            backContent: """
            The Renaissance was a period of cultural rebirth in Europe from the 14th to 17th century. \
            It marked the transition from the Middle Ages to modernity, characterized by a renewed \
            interest in classical learning, art, and humanism.

            Key figures include Leonardo da Vinci, Michelangelo, and Raphael, whose works continue \
            to inspire artists today. The Renaissance began in Florence, Italy, and spread across Europe, \
            fundamentally changing how people viewed the world and their place in it.
            """,
            tags: ["Renaissance", "Art History", "Europe", "Cultural Movement"],
            source: "Encyclopedia Britannica",
            difficulty: difficulty,
            estimatedReadTime: 120,
            createdAt: Date()
        )
    }

    /// Create an array of mock cards for testing
    static func mockArray(count: Int = 5) -> [Card] {
        let categories = Category.allCases
        return (0..<count).map { index in
            let category = categories[index % categories.count]
            return Card.mock(
                id: UUID(),
                title: mockTitles[index % mockTitles.count],
                category: category,
                difficulty: (index % 5) + 1
            )
        }
    }

    private static let mockTitles = [
        "The Renaissance Revolution",
        "Quantum Physics Explained",
        "Understanding Impressionism",
        "The Science of Sleep",
        "Introduction to Stock Markets",
        "Stoic Philosophy Basics",
        "World War II Turning Points",
        "DNA and Genetics",
        "Modern Architecture",
        "Cognitive Biases"
    ]
}
#endif
