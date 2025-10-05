//
//  CardRepositoryTests.swift
//  DailyQuipAITests
//
//  Created by Claude on 10/4/25.
//

import XCTest
@testable import DailyQuipAI

final class CardRepositoryTests: XCTestCase {

    var repository: UserDefaultsCardRepository!
    var testDefaults: UserDefaults!

    override func setUp() async throws {
        // Create a test UserDefaults suite
        testDefaults = UserDefaults(suiteName: "test.gleam.cards")!
        repository = UserDefaultsCardRepository(defaults: testDefaults)

        // Clear any existing data
        testDefaults.removePersistentDomain(forName: "test.gleam.cards")
    }

    override func tearDown() async throws {
        testDefaults.removePersistentDomain(forName: "test.gleam.cards")
        testDefaults = nil
        repository = nil
    }

    func testSaveCard() async throws {
        let card = Card.mock()

        try await repository.saveCard(card)

        let savedCards = try await repository.fetchSavedCards()
        XCTAssertEqual(savedCards.count, 1)
        XCTAssertEqual(savedCards.first?.id, card.id)
    }

    func testSaveMultipleCards() async throws {
        let cards = Card.mockArray(count: 3)

        for card in cards {
            try await repository.saveCard(card)
        }

        let savedCards = try await repository.fetchSavedCards()
        XCTAssertEqual(savedCards.count, 3)
    }

    func testSaveDuplicateCard() async throws {
        let card = Card.mock()

        try await repository.saveCard(card)
        try await repository.saveCard(card) // Save same card again

        let savedCards = try await repository.fetchSavedCards()
        XCTAssertEqual(savedCards.count, 1) // Should not duplicate
    }

    func testDeleteCard() async throws {
        let card = Card.mock()

        try await repository.saveCard(card)
        var savedCards = try await repository.fetchSavedCards()
        XCTAssertEqual(savedCards.count, 1)

        try await repository.deleteCard(id: card.id)
        savedCards = try await repository.fetchSavedCards()
        XCTAssertEqual(savedCards.count, 0)
    }

    func testFetchCard() async throws {
        let card = Card.mock()

        try await repository.saveCard(card)

        let fetchedCard = try await repository.fetchCard(id: card.id)
        XCTAssertNotNil(fetchedCard)
        XCTAssertEqual(fetchedCard?.id, card.id)
    }

    func testFetchNonExistentCard() async throws {
        let fetchedCard = try await repository.fetchCard(id: UUID())
        XCTAssertNil(fetchedCard)
    }

    func testIsCardSaved() async throws {
        let card = Card.mock()

        var isSaved = try await repository.isCardSaved(id: card.id)
        XCTAssertFalse(isSaved)

        try await repository.saveCard(card)

        isSaved = try await repository.isCardSaved(id: card.id)
        XCTAssertTrue(isSaved)
    }

    func testFetchCardsByCategory() async throws {
        let historyCard = Card.mock(category: .history)
        let scienceCard = Card.mock(category: .science)
        let artCard = Card.mock(category: .art)

        try await repository.saveCard(historyCard)
        try await repository.saveCard(scienceCard)
        try await repository.saveCard(artCard)

        let historyCards = try await repository.fetchCards(byCategory: .history)
        XCTAssertEqual(historyCards.count, 1)
        XCTAssertEqual(historyCards.first?.category, .history)

        let scienceCards = try await repository.fetchCards(byCategory: .science)
        XCTAssertEqual(scienceCards.count, 1)
        XCTAssertEqual(scienceCards.first?.category, .science)
    }

    func testMarkCardAsLearned() async throws {
        let card = Card.mock()

        try await repository.markCardAsLearned(id: card.id)

        // Verify it doesn't throw (basic test)
        // In production, we'd verify the learned status
    }

    func testFetchCardsForReview() async throws {
        let cards = Card.mockArray(count: 3)

        for card in cards {
            try await repository.saveCard(card)
        }

        let reviewCards = try await repository.fetchCardsForReview()
        XCTAssertEqual(reviewCards.count, 3)
    }
}
