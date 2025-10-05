//
//  DailyCardsViewModelTests.swift
//  DailyQuipAITests
//
//  Created by Claude on 10/4/25.
//

import XCTest
@testable import DailyQuipAI

final class DailyCardsViewModelTests: XCTestCase {

    var viewModel: DailyCardsViewModel!
    var mockAPIClient: MockAPIClient!
    var mockCardRepository: MockCardRepository!
    var mockUserRepository: MockUserRepository!
    var mockLLMGenerator: MockLLMCardGenerator!

    @MainActor
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        mockCardRepository = MockCardRepository()
        mockUserRepository = MockUserRepository()
        mockLLMGenerator = MockLLMCardGenerator()
        viewModel = DailyCardsViewModel(
            apiClient: mockAPIClient,
            cardRepository: mockCardRepository,
            userRepository: mockUserRepository,
            llmGenerator: mockLLMGenerator
        )
    }

    override func tearDown() {
        viewModel = nil
        mockAPIClient = nil
        mockCardRepository = nil
        mockUserRepository = nil
        mockLLMGenerator = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    @MainActor
    func testInitialState() {
        XCTAssertTrue(viewModel.cards.isEmpty)
        XCTAssertEqual(viewModel.currentCardIndex, 0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertFalse(viewModel.showError)
    }

    // MARK: - Computed Properties Tests

    @MainActor
    func testCurrentCardWhenEmpty() {
        XCTAssertNil(viewModel.currentCard)
    }

    @MainActor
    func testCurrentCardWhenPresent() {
        let cards = Card.mockArray(count: 3)
        viewModel.cards = cards
        viewModel.currentCardIndex = 0

        XCTAssertEqual(viewModel.currentCard?.id, cards[0].id)
    }

    @MainActor
    func testHasMoreCardsWhenEmpty() {
        XCTAssertFalse(viewModel.hasMoreCards)
    }

    @MainActor
    func testHasMoreCardsWhenPresent() {
        viewModel.cards = Card.mockArray(count: 3)
        viewModel.currentCardIndex = 0

        XCTAssertTrue(viewModel.hasMoreCards)
    }

    @MainActor
    func testHasMoreCardsWhenCompleted() {
        viewModel.cards = Card.mockArray(count: 3)
        viewModel.currentCardIndex = 3

        XCTAssertFalse(viewModel.hasMoreCards)
    }

    @MainActor
    func testProgress() {
        viewModel.cards = Card.mockArray(count: 5)
        viewModel.currentCardIndex = 2

        XCTAssertEqual(viewModel.progress, 0.4, accuracy: 0.01)
    }

    @MainActor
    func testProgressWhenEmpty() {
        XCTAssertEqual(viewModel.progress, 0.0)
    }

    @MainActor
    func testCardsCompleted() {
        viewModel.currentCardIndex = 3
        XCTAssertEqual(viewModel.cardsCompleted, 3)
    }

    @MainActor
    func testTotalCards() {
        viewModel.cards = Card.mockArray(count: 5)
        XCTAssertEqual(viewModel.totalCards, 5)
    }

    // MARK: - Fetch Daily Cards Tests

    @MainActor
    func testFetchDailyCardsSuccess() async {
        // Setup mock LLM generator
        let mockCards = Card.mockArray(count: 3)
        mockLLMGenerator.mockCards = mockCards

        // Fetch cards
        await viewModel.fetchDailyCards()

        // Verify
        XCTAssertEqual(viewModel.cards.count, 3)
        XCTAssertEqual(viewModel.currentCardIndex, 0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testFetchDailyCardsFailure() async {
        // Setup mock error
        mockLLMGenerator.shouldFail = true
        mockLLMGenerator.mockError = LLMError.invalidResponse

        // Fetch cards
        await viewModel.fetchDailyCards()

        // Verify
        XCTAssertTrue(viewModel.cards.isEmpty)
        XCTAssertNotNil(viewModel.error)
        XCTAssertTrue(viewModel.showError)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Mark As Learned Tests

    @MainActor
    func testMarkAsLearnedSuccess() async {
        // Setup
        viewModel.cards = Card.mockArray(count: 3)
        viewModel.currentCardIndex = 0
        let initialIndex = viewModel.currentCardIndex

        // Mark as learned
        await viewModel.markAsLearned()

        // Verify card was marked as learned
        XCTAssertTrue(mockCardRepository.markedAsLearnedIDs.contains(viewModel.cards[initialIndex].id))

        // Verify moved to next card
        XCTAssertEqual(viewModel.currentCardIndex, initialIndex + 1)
    }

    @MainActor
    func testMarkAsLearnedWhenNoCard() async {
        // No cards
        viewModel.cards = []
        viewModel.currentCardIndex = 0

        // Mark as learned should not crash
        await viewModel.markAsLearned()

        XCTAssertTrue(mockCardRepository.markedAsLearnedIDs.isEmpty)
    }

    // MARK: - Save Card Tests

    @MainActor
    func testSaveCardSuccess() async {
        // Setup
        viewModel.cards = Card.mockArray(count: 3)
        viewModel.currentCardIndex = 0
        let initialIndex = viewModel.currentCardIndex

        // Save card
        await viewModel.saveCard()

        // Verify card was saved
        XCTAssertEqual(mockCardRepository.savedCards.count, 1)
        XCTAssertEqual(mockCardRepository.savedCards.first?.id, viewModel.cards[initialIndex].id)

        // Verify moved to next card
        XCTAssertEqual(viewModel.currentCardIndex, initialIndex + 1)
    }

    @MainActor
    func testSaveCardWhenNoCard() async {
        // No cards
        viewModel.cards = []
        viewModel.currentCardIndex = 0

        // Save card should not crash
        await viewModel.saveCard()

        XCTAssertTrue(mockCardRepository.savedCards.isEmpty)
    }

    // MARK: - Move to Next Card Tests

    @MainActor
    func testMoveToNextCard() {
        viewModel.cards = Card.mockArray(count: 3)
        viewModel.currentCardIndex = 0

        viewModel.moveToNextCard()

        XCTAssertEqual(viewModel.currentCardIndex, 1)
    }

    // MARK: - Retry Tests

    @MainActor
    func testRetry() async {
        // Setup initial error state
        mockLLMGenerator.shouldFail = true
        mockLLMGenerator.mockError = LLMError.invalidResponse
        await viewModel.fetchDailyCards()
        XCTAssertNotNil(viewModel.error)

        // Now make it succeed
        mockLLMGenerator.shouldFail = false
        let mockCards = Card.mockArray(count: 3)
        mockLLMGenerator.mockCards = mockCards

        // Retry
        await viewModel.retry()

        // Verify success
        XCTAssertEqual(viewModel.cards.count, 3)
        XCTAssertFalse(viewModel.isLoading)
    }
}

// MARK: - Mock LLM Generator

class MockLLMCardGenerator: LLMCardGenerator {
    var mockCards: [Card] = []
    var shouldFail = false
    var mockError: Error?

    init() {
        super.init(apiKey: "test-key", provider: .gemini)
    }

    override func generateDailyCards(categories: [DailyQuipAI.Category], count: Int) async throws -> [Card] {
        if shouldFail {
            throw mockError ?? LLMError.invalidResponse
        }

        return Array(mockCards.prefix(count))
    }
}

// MARK: - Mock Repositories

class MockCardRepository: CardRepository {
    var savedCards: [Card] = []
    var markedAsLearnedIDs: [UUID] = []
    var deletedIDs: [UUID] = []

    func fetchDailyCards() async throws -> [Card] {
        return []
    }

    func saveCard(_ card: Card) async throws {
        savedCards.append(card)
    }

    func fetchSavedCards() async throws -> [Card] {
        return savedCards
    }

    func deleteCard(id cardId: UUID) async throws {
        deletedIDs.append(cardId)
        savedCards.removeAll { $0.id == cardId }
    }

    func markCardAsLearned(id cardId: UUID) async throws {
        markedAsLearnedIDs.append(cardId)
    }

    func isCardSaved(id cardId: UUID) async throws -> Bool {
        return savedCards.contains { $0.id == cardId }
    }

    func fetchCard(id cardId: UUID) async throws -> Card? {
        return savedCards.first { $0.id == cardId }
    }

    func fetchCards(byCategory category: DailyQuipAI.Category) async throws -> [Card] {
        return savedCards.filter { $0.category == category }
    }

    func fetchCardsForReview() async throws -> [Card] {
        return savedCards
    }
}

class MockUserRepository: UserRepository {
    var mockUser: User?
    var updateCalled = false

    func fetchUser() async throws -> User? {
        return mockUser
    }

    func saveUser(_ user: User) async throws {
        mockUser = user
        updateCalled = true
    }

    func deleteUser() async throws {
        mockUser = nil
    }

    func incrementStreak() async throws {
        mockUser?.incrementStreak()
    }

    func resetStreak() async throws {
        mockUser?.resetStreak()
    }

    func updateSettings(_ settings: UserSettings) async throws {
        mockUser?.settings = settings
    }

    func incrementCardsLearned() async throws {
        mockUser?.addCardLearned()
    }
}
