//
//  CardTests.swift
//  DailyQuipAITests
//
//  Created by Claude on 10/4/25.
//

import XCTest
@testable import DailyQuipAI

final class CardTests: XCTestCase {

    func testCardCreation() {
        // Test creating a card with all properties
        let id = UUID()
        let card = Card(
            id: id,
            title: "Test Card",
            category: .history,
            frontImageURL: URL(string: "https://example.com/image.jpg")!,
            backContent: "Test content",
            tags: ["test", "sample"],
            source: "Test Source",
            difficulty: 3,
            estimatedReadTime: 120,
            createdAt: Date()
        )

        XCTAssertEqual(card.id, id)
        XCTAssertEqual(card.title, "Test Card")
        XCTAssertEqual(card.category, .history)
        XCTAssertEqual(card.tags.count, 2)
        XCTAssertEqual(card.difficulty, 3)
    }

    func testCardDifficultyStars() {
        // Test difficulty star formatting
        let card1 = Card.mock(difficulty: 1)
        XCTAssertEqual(card1.difficultyStars, "⭐")

        let card3 = Card.mock(difficulty: 3)
        XCTAssertEqual(card3.difficultyStars, "⭐⭐⭐")

        let card5 = Card.mock(difficulty: 5)
        XCTAssertEqual(card5.difficultyStars, "⭐⭐⭐⭐⭐")
    }

    func testCardReadTimeFormatted() {
        // Test read time formatting
        let card60 = Card(
            id: UUID(),
            title: "Test",
            category: .science,
            frontImageURL: URL(string: "https://example.com/image.jpg")!,
            backContent: "Content",
            tags: [],
            source: "Source",
            difficulty: 1,
            estimatedReadTime: 60,
            createdAt: Date()
        )
        XCTAssertTrue(card60.readTimeFormatted.contains("1m"))

        let card45 = Card(
            id: UUID(),
            title: "Test",
            category: .science,
            frontImageURL: URL(string: "https://example.com/image.jpg")!,
            backContent: "Content",
            tags: [],
            source: "Source",
            difficulty: 1,
            estimatedReadTime: 45,
            createdAt: Date()
        )
        XCTAssertTrue(card45.readTimeFormatted.contains("45s"))
    }

    func testCardEquatable() {
        // Test that cards with same properties are equal
        let id = UUID()
        let date = Date()
        let card1 = Card(
            id: id,
            title: "Card 1",
            category: .history,
            frontImageURL: URL(string: "https://example.com/image.jpg")!,
            backContent: "Content 1",
            tags: [],
            source: "Source",
            difficulty: 1,
            estimatedReadTime: 60,
            createdAt: date
        )

        let card2 = Card(
            id: id,
            title: "Card 1",
            category: .history,
            frontImageURL: URL(string: "https://example.com/image.jpg")!,
            backContent: "Content 1",
            tags: [],
            source: "Source",
            difficulty: 1,
            estimatedReadTime: 60,
            createdAt: date
        )

        XCTAssertEqual(card1, card2)
    }

    func testCardCodable() throws {
        // Test encoding
        let card = Card.mock()
        let encoder = JSONEncoder()
        let data = try encoder.encode(card)
        XCTAssertFalse(data.isEmpty)

        // Test decoding
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Card.self, from: data)
        XCTAssertEqual(decoded.id, card.id)
        XCTAssertEqual(decoded.title, card.title)
        XCTAssertEqual(decoded.category, card.category)
    }

    func testCardMockData() {
        // Test mock data generation
        let card = Card.mock()
        XCTAssertFalse(card.title.isEmpty)
        XCTAssertFalse(card.backContent.isEmpty)
        XCTAssertGreaterThan(card.difficulty, 0)
        XCTAssertLessThanOrEqual(card.difficulty, 5)
    }

    func testCardMockArray() {
        // Test generating multiple mock cards
        let cards = Card.mockArray(count: 10)
        XCTAssertEqual(cards.count, 10)

        // Verify all cards have unique IDs
        let uniqueIDs = Set(cards.map { $0.id })
        XCTAssertEqual(uniqueIDs.count, 10)

        // Verify categories are distributed
        let categories = Set(cards.map { $0.category })
        XCTAssertGreaterThan(categories.count, 1)
    }
}
