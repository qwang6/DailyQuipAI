//
//  CardRepository.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import Foundation

/// Protocol for card data access
protocol CardRepository {
    /// Fetch today's daily cards
    func fetchDailyCards() async throws -> [Card]

    /// Fetch a specific card by ID
    /// - Parameter id: The card ID
    /// - Returns: The card if found
    func fetchCard(id: UUID) async throws -> Card?

    /// Save a card to the user's collection
    /// - Parameter card: The card to save
    func saveCard(_ card: Card) async throws

    /// Remove a card from the user's collection
    /// - Parameter id: The card ID to remove
    func deleteCard(id: UUID) async throws

    /// Fetch all saved cards
    /// - Returns: Array of saved cards
    func fetchSavedCards() async throws -> [Card]

    /// Check if a card is saved
    /// - Parameter id: The card ID
    /// - Returns: True if the card is saved
    func isCardSaved(id: UUID) async throws -> Bool

    /// Fetch cards by category
    /// - Parameter category: The category to filter by
    /// - Returns: Array of cards in that category
    func fetchCards(byCategory category: Category) async throws -> [Card]

    /// Mark a card as learned
    /// - Parameter id: The card ID
    func markCardAsLearned(id: UUID) async throws

    /// Fetch cards that need review
    /// - Returns: Array of cards due for review
    func fetchCardsForReview() async throws -> [Card]
}

/// UserDefaults-based implementation of CardRepository (temporary until API is ready)
/// This stores card IDs in UserDefaults and works with in-memory card data
class UserDefaultsCardRepository: CardRepository {

    private let savedCardsKey = "gleam.savedCards"
    private let learnedCardsKey = "gleam.learnedCards"
    private let dailyCardsKey = "gleam.dailyCards"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func fetchDailyCards() async throws -> [Card] {
        // For now, return empty array
        // This will be populated by the API in M1.4
        return []
    }

    func fetchCard(id: UUID) async throws -> Card? {
        let savedCards = try await fetchSavedCards()
        return savedCards.first { $0.id == id }
    }

    func saveCard(_ card: Card) async throws {
        var savedCards = try await fetchSavedCards()

        // Don't save duplicates
        if !savedCards.contains(where: { $0.id == card.id }) {
            savedCards.append(card)
            try saveCardsToDefaults(savedCards)
        }
    }

    func deleteCard(id: UUID) async throws {
        var savedCards = try await fetchSavedCards()
        savedCards.removeAll { $0.id == id }
        try saveCardsToDefaults(savedCards)
    }

    func fetchSavedCards() async throws -> [Card] {
        guard let data = defaults.data(forKey: savedCardsKey) else {
            return []
        }

        let decoder = JSONDecoder()
        return try decoder.decode([Card].self, from: data)
    }

    func isCardSaved(id: UUID) async throws -> Bool {
        let savedCards = try await fetchSavedCards()
        return savedCards.contains { $0.id == id }
    }

    func fetchCards(byCategory category: Category) async throws -> [Card] {
        let savedCards = try await fetchSavedCards()
        return savedCards.filter { $0.category == category }
    }

    func markCardAsLearned(id: UUID) async throws {
        var learnedCardIDs = getLearnedCardIDs()
        if !learnedCardIDs.contains(id) {
            learnedCardIDs.append(id)
            saveLearnedCardIDs(learnedCardIDs)
        }
    }

    func fetchCardsForReview() async throws -> [Card] {
        // Simple implementation: return all saved cards
        // In the future, this will use spaced repetition logic
        return try await fetchSavedCards()
    }

    // MARK: - Private Helpers

    private func saveCardsToDefaults(_ cards: [Card]) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(cards)
        defaults.set(data, forKey: savedCardsKey)
    }

    private func getLearnedCardIDs() -> [UUID] {
        guard let data = defaults.data(forKey: learnedCardsKey) else {
            return []
        }
        return (try? JSONDecoder().decode([UUID].self, from: data)) ?? []
    }

    private func saveLearnedCardIDs(_ ids: [UUID]) {
        let data = try? JSONEncoder().encode(ids)
        defaults.set(data, forKey: learnedCardsKey)
    }
}

// MARK: - Mock Repository for Testing
#if DEBUG
class MockCardRepository: CardRepository {
    var savedCards: [Card] = []
    var dailyCards: [Card] = []
    var learnedCardIDs: Set<UUID> = []
    var shouldThrowError = false

    func fetchDailyCards() async throws -> [Card] {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        return dailyCards
    }

    func fetchCard(id: UUID) async throws -> Card? {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        return savedCards.first { $0.id == id }
    }

    func saveCard(_ card: Card) async throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        if !savedCards.contains(where: { $0.id == card.id }) {
            savedCards.append(card)
        }
    }

    func deleteCard(id: UUID) async throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        savedCards.removeAll { $0.id == id }
    }

    func fetchSavedCards() async throws -> [Card] {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        return savedCards
    }

    func isCardSaved(id: UUID) async throws -> Bool {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        return savedCards.contains { $0.id == id }
    }

    func fetchCards(byCategory category: Category) async throws -> [Card] {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        return savedCards.filter { $0.category == category }
    }

    func markCardAsLearned(id: UUID) async throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        learnedCardIDs.insert(id)
    }

    func fetchCardsForReview() async throws -> [Card] {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        return savedCards
    }
}
#endif
