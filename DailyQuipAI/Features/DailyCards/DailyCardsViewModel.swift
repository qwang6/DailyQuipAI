//
//  DailyCardsViewModel.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import SwiftUI
import Combine

/// View model for daily cards feature
@MainActor
class DailyCardsViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var cards: [Card] = []
    @Published var currentCardIndex: Int = 0
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var showError: Bool = false
    @Published var selectedCategory: Category?  // nil = all categories

    // MARK: - Cache Keys

    private let cachedCardsKey = "cachedDailyCards"
    private let lastFetchDateKey = "lastCardFetchDate"
    private let nextBatchCacheKey = "nextBatchDailyCards"
    private let lastCardIndexKey = "lastViewedCardIndex"
    private let lastCategoryKey = "lastSelectedCategory"

    // MARK: - Prefetch State

    private var isPrefetching: Bool = false
    private var nextBatchCards: [Card] = []
    private var isLoadingNextBatch: Bool = false  // Track if we're loading the next batch

    // MARK: - Category-based Storage

    // Store all cards by category for efficient filtering
    private var allCardsByCategory: [Category: [Card]] = [:]

    // MARK: - Computed Properties

    var currentCard: Card? {
        guard currentCardIndex < cards.count else { return nil }
        return cards[currentCardIndex]
    }

    var llmGeneratorInstance: LLMCardGenerator {
        llmGenerator
    }

    var hasMoreCards: Bool {
        // In a free app with unlimited LLM generation, we ALWAYS have more cards
        // The only case where we don't is if we're still on existing cards
        // When currentCardIndex >= cards.count, we'll trigger loadNextBatch
        // So hasMoreCards should always be true (we can always generate more)
        return true
    }

    var progress: Double {
        guard !cards.isEmpty else { return 0 }
        return Double(currentCardIndex) / Double(cards.count)
    }

    var cardsCompleted: Int {
        currentCardIndex
    }

    var totalCards: Int {
        cards.count
    }

    // MARK: - Dependencies

    private let apiClient: APIClient
    private let cardRepository: CardRepository
    private let userRepository: UserRepository
    private let llmGenerator: LLMCardGenerator
    private let subscriptionManager = SubscriptionManager.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        apiClient: APIClient,
        cardRepository: CardRepository,
        userRepository: UserRepository,
        llmGenerator: LLMCardGenerator
    ) {
        self.apiClient = apiClient
        self.cardRepository = cardRepository
        self.userRepository = userRepository
        self.llmGenerator = llmGenerator
    }

    convenience init() {
        let baseURL = URL(string: "https://api.gleam.app")!

        // Get Gemini API key from Configuration (which handles .env and environment variables)
        let apiKey = Configuration.geminiAPIKey

        self.init(
            apiClient: URLSessionAPIClient(baseURL: baseURL),
            cardRepository: UserDefaultsCardRepository(),
            userRepository: UserDefaultsUserRepository(),
            llmGenerator: LLMCardGenerator(apiKey: apiKey, provider: .gemini, modelName: "gemini-2.5-flash-lite")
        )
    }

    // MARK: - Public Methods

    /// Fetch daily cards - uses cache if available, generates new cards when cache is exhausted
    func fetchDailyCards() async {
        print("📱 fetchDailyCards called")

        // Load all cards from cache or fetch new
        await loadOrFetchAllCards()

        // Restore last category selection
        restoreLastCategory()

        // Apply category filter
        applyFilter()

        // Restore last card position
        restoreLastCardPosition()

        print("✅ Restored to card index: \(currentCardIndex) in category: \(selectedCategory?.rawValue ?? "All")")
    }

    /// Switch to a specific category or show all
    func switchCategory(_ category: Category?) async {
        selectedCategory = category
        currentCardIndex = 0

        // Save category preference
        saveLastCategory()
        saveLastCardPosition()

        if let category = category {
            // Check if we have cards for this category
            if let existingCards = allCardsByCategory[category], !existingCards.isEmpty {
                print("📚 Switching to category \(category.rawValue): \(existingCards.count) existing cards")
                cards = existingCards

                // Fetch more cards if needed
                if existingCards.count < 5 {
                    print("⚠️ Low card count for \(category.rawValue), fetching more...")
                    await fetchCardsForCategory(category)
                }
            } else {
                // No cards for this category - set loading state and fetch new batch
                print("📭 No cards for \(category.rawValue), fetching new batch...")
                cards = []  // Ensure cards is empty
                isLoading = true  // Set loading before async call
                await fetchCardsForCategory(category)
            }
        } else {
            // Show all categories
            applyFilter()
        }
    }

    /// Fetch cards specifically for a category and append to existing
    private func fetchCardsForCategory(_ category: Category, isAppendingBatch: Bool = false) async {
        if !isAppendingBatch {
            isLoading = true
        }
        error = nil

        do {
            let cardCount = 5  // Fetch a batch for this category (reduced for faster response)

            print("🔄 Fetching \(cardCount) cards for \(category.rawValue)...")

            // Generate cards for specific category
            let newCards = try await llmGenerator.generateDailyCards(
                categories: [category],  // Only this category
                count: cardCount
            )

            // Append to existing cards for this category
            var existingCards = allCardsByCategory[category] ?? []
            let oldCount = existingCards.count
            existingCards.append(contentsOf: newCards)
            allCardsByCategory[category] = existingCards

            // Update displayed cards on main actor to ensure UI updates
            await MainActor.run {
                if isAppendingBatch {
                    // When appending, update cards but don't reset index
                    self.cards = existingCards
                    print("📍 Keeping card index at \(self.currentCardIndex), cards now: \(existingCards.count)")
                } else {
                    // When switching category, reset to first card
                    self.cards = existingCards
                    self.currentCardIndex = 0
                }
                self.isLoading = false
            }

            // Save to cache
            saveCategoryCards()

            print("✅ Fetched \(newCards.count) new cards for \(category.rawValue), was: \(oldCount), now: \(existingCards.count)")

        } catch {
            self.error = error
            self.showError = true
            self.isLoading = false
        }
    }

    /// Load all cards or fetch if needed
    private func loadOrFetchAllCards() async {
        // Try to load from cache first
        if loadAllCategoryCards() {
            print("✅ Loaded cards from cache")
            return
        }

        // No cache - fetch new cards for all categories
        await fetchNewCards()
    }

    /// Apply category filter to displayed cards
    /// - Parameter resetIndex: Whether to reset currentCardIndex to 0 (default true)
    private func applyFilter(resetIndex: Bool = true) {
        if let category = selectedCategory {
            cards = allCardsByCategory[category] ?? []
            print("🔍 Filtered to \(category.rawValue): \(cards.count) cards")
        } else {
            // Show all cards from all categories
            cards = allCardsByCategory.values.flatMap { $0 }
            print("🔍 Showing all cards: \(cards.count) total")
        }
        if resetIndex {
            currentCardIndex = 0
            print("🔄 Reset card index to 0")
        } else {
            print("📍 Keeping card index at \(currentCardIndex)")
        }
    }

    /// Force fetch new cards from LLM - fetches for all selected categories
    /// - Parameter isAppendingBatch: True if appending to existing cards (don't reset index), false for fresh load
    private func fetchNewCards(isAppendingBatch: Bool = false) async {
        isLoading = true
        error = nil

        do {
            let selectedCategories = getSelectedCategories()
            let dailyGoal = UserDefaults.standard.integer(forKey: "dailyGoal")

            // For free users: enforce 5 card limit regardless of settings
            // Use daily goal setting for all users
            let cardCount = dailyGoal > 0 ? dailyGoal : 5

            print("🔄 Fetching \(cardCount) new cards from LLM...")

            // Generate cards using LLM (single batch request)
            let newCards = try await llmGenerator.generateDailyCards(
                categories: selectedCategories,
                count: cardCount
            )

            // Organize cards by category
            for card in newCards {
                var categoryCards = allCardsByCategory[card.category] ?? []
                categoryCards.append(card)
                allCardsByCategory[card.category] = categoryCards
            }

            // Apply filter to set displayed cards
            // If appending, don't reset index - continue from current position
            applyFilter(resetIndex: !isAppendingBatch)

            // Save to cache
            saveCategoryCards()

            print("✅ Fetched and cached \(newCards.count) cards across \(allCardsByCategory.keys.count) categories")
            isLoading = false

            // Start prefetching next batch
            Task {
                await prefetchNextBatch()
            }

        } catch {
            self.error = error
            self.showError = true
            self.isLoading = false
        }
    }

    /// Mark card as learned and move to next
    func markAsLearned() async {
        guard let card = currentCard else { return }

        do {
            try await cardRepository.markCardAsLearned(id: card.id)
            await updateUserProgress()
            moveToNextCard()
        } catch {
            self.error = error
            self.showError = true
        }
    }

    /// Save card for later and move to next
    func saveCard() async {
        guard let card = currentCard else { return }

        do {
            try await cardRepository.saveCard(card)
            await updateUserProgress()
            moveToNextCard()
        } catch {
            self.error = error
            self.showError = true
        }
    }

    /// Move to next card
    func moveToNextCard() {
        print("🔄 moveToNextCard called - currentIndex: \(currentCardIndex), totalCards: \(cards.count)")

        // Force UI refresh to reset card state
        let nextIndex = currentCardIndex + 1

        // Check if we're actually moving to a new card
        guard nextIndex > currentCardIndex else {
            print("⚠️ Not moving - same index")
            return
        }

        // Check if this is a NEW card (beyond what user has viewed)
        let maxViewedIndex = subscriptionManager.cardsViewedToday - 1  // Convert count to index
        let isNewCard = nextIndex > maxViewedIndex

        // Debug: Check subscription state
        print("🔍 Pre-limit check:")
        print("   - currentCardIndex: \(currentCardIndex)")
        print("   - nextIndex: \(nextIndex)")
        print("   - cardsViewedToday: \(subscriptionManager.cardsViewedToday)")
        print("   - maxViewedIndex: \(maxViewedIndex)")
        print("   - isNewCard: \(isNewCard)")
        print("   - dailyCardLimit: \(subscriptionManager.dailyCardLimit?.description ?? "unlimited")")
        print("   - canViewMoreCards: \(subscriptionManager.canViewMoreCards)")

        // No limits - completely free app
        // Removed paywall logic

        // Track viewed count for statistics only
        if isNewCard {
            subscriptionManager.incrementCardsViewed()
            print("✅ Card viewed count: \(subscriptionManager.cardsViewedToday)")
        } else {
            print("⏪ Reviewing previous card - no increment")
        }

        withAnimation(.spring()) {
            currentCardIndex = nextIndex
            print("📈 Moving to card index: \(currentCardIndex)")

            // Save position after moving
            saveLastCardPosition()

            // When all cards in current batch are viewed, load next batch
            if currentCardIndex >= cards.count {
                print("🎉 All cards in current batch viewed!")
                Task {
                    await loadNextBatch()
                }
            } else {
                // Update cache to track progress
                updateCacheAfterViewing()

                // Prefetch next batch when user is on second-to-last card
                let cardsRemaining = cards.count - currentCardIndex
                print("📊 Cards remaining: \(cardsRemaining)")
                if cardsRemaining == 1 && !isPrefetching {
                    print("🔮 Triggering prefetch for next batch")
                    Task {
                        await prefetchNextBatch()
                    }
                }
            }
        }
    }

    /// Move to previous card (allow reviewing already-viewed cards)
    func moveToPreviousCard() {
        print("⏮️ moveToPreviousCard called - currentIndex: \(currentCardIndex)")

        guard currentCardIndex > 0 else {
            print("⚠️ Already at first card")
            return
        }

        withAnimation(.spring()) {
            currentCardIndex -= 1
            print("📉 Moving back to card index: \(currentCardIndex)")
            saveLastCardPosition()
        }
    }

    /// Refresh current card (force UI reset)
    func refreshCurrentCard() {
        objectWillChange.send()
    }

    /// Load the next batch of cards (from prefetch or fetch new)
    private func loadNextBatch() async {
        // No limits - completely free app
        // Removed paywall logic

        // Mark that we're loading to prevent showing "completed" screen
        isLoadingNextBatch = true
        print("🔄 Started loading next batch...")

        if !nextBatchCards.isEmpty {
            print("📦 Loading prefetched next batch: \(nextBatchCards.count) cards")

            // Append new cards to the corresponding categories
            for card in nextBatchCards {
                var categoryCards = allCardsByCategory[card.category] ?? []
                categoryCards.append(card)
                allCardsByCategory[card.category] = categoryCards
            }

            // Reapply filter to update displayed cards
            if let category = selectedCategory {
                cards = allCardsByCategory[category] ?? []
                print("🔍 Updated \(category.rawValue): now \(cards.count) cards")
            } else {
                cards = allCardsByCategory.values.flatMap { $0 }
                print("🔍 Updated all cards: now \(cards.count) total")
            }

            // DON'T reset to 0 - keep current index to continue from where we were
            // User has already viewed oldCardsCount cards, now show the new ones
            // currentCardIndex stays at oldCardsCount, which points to first new card
            print("📍 Continuing from card index: \(currentCardIndex) (should be first new card)")

            nextBatchCards = []
            saveCategoryCards()

            // Clear loading flag
            isLoadingNextBatch = false
            print("✅ Finished loading next batch")

            // Start prefetching the next batch
            Task {
                await prefetchNextBatch()
            }
        } else {
            print("⚠️ No prefetched batch available, fetching new cards...")
            // IMPORTANT: Wait for fetch to complete before returning
            // This ensures cards array is updated before UI tries to display

            // If user has selected a category, fetch cards for that category only
            // Otherwise fetch for all selected categories
            if let currentCategory = selectedCategory {
                await fetchCardsForCategory(currentCategory, isAppendingBatch: true)
            } else {
                await fetchNewCards(isAppendingBatch: true)
            }

            // Clear loading flag
            isLoadingNextBatch = false
            print("✅ Finished loading next batch")
        }
    }

    /// Prefetch the next batch of cards in the background
    private func prefetchNextBatch() async {
        guard !isPrefetching else {
            print("⏭️ Already prefetching, skipping...")
            return
        }

        isPrefetching = true
        print("🔮 Prefetching next batch in background...")

        do {
            let dailyGoal = UserDefaults.standard.integer(forKey: "dailyGoal")
            let cardCount = dailyGoal > 0 ? dailyGoal : 5

            // If user has selected a category, prefetch cards for that category only
            // Otherwise prefetch for all selected categories
            let categoriesToFetch: [Category]
            if let currentCategory = selectedCategory {
                categoriesToFetch = [currentCategory]
                print("🔮 Prefetching for current category: \(currentCategory.rawValue)")
            } else {
                categoriesToFetch = getSelectedCategories()
                print("🔮 Prefetching for all selected categories")
            }

            // Generate next batch using LLM
            let prefetchedCards = try await llmGenerator.generateDailyCards(
                categories: categoriesToFetch,
                count: cardCount
            )

            nextBatchCards = prefetchedCards
            cacheNextBatch(prefetchedCards)
            print("✅ Prefetched \(prefetchedCards.count) cards for next batch")

        } catch {
            print("⚠️ Failed to prefetch next batch: \(error.localizedDescription)")
            // Silent fail - user will see loading when they reach the end
        }

        isPrefetching = false
    }

    /// Retry loading after error
    func retry() async {
        await fetchDailyCards()
    }

    // MARK: - Private Methods

    private func getSelectedCategories() -> [Category] {
        guard let categoryStrings = UserDefaults.standard.stringArray(forKey: "selectedCategories"),
              !categoryStrings.isEmpty else {
            return Category.allCases
        }

        return categoryStrings.compactMap { Category(rawValue: $0) }
    }

    private func updateUserProgress() async {
        do {
            if var user = try await userRepository.fetchUser() {
                user.addCardLearned()
                try await userRepository.saveUser(user)
            }
        } catch {
            // Silent fail - progress update is not critical
            print("Failed to update user progress: \(error)")
        }
    }

    // MARK: - Cache Management

    /// Load all category cards from cache
    private func loadAllCategoryCards() -> Bool {
        // Check if cache is from today
        if let lastFetchDate = UserDefaults.standard.object(forKey: lastFetchDateKey) as? Date {
            let calendar = Calendar.current
            if !calendar.isDateInToday(lastFetchDate) {
                print("⏰ Cache expired (from \(lastFetchDate))")
                clearCache()
                return false
            }
        }

        // Load cached cards by category
        guard let cardsData = UserDefaults.standard.data(forKey: cachedCardsKey) else {
            print("📭 No cached cards found")
            return false
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        // Try new format first (category-based dictionary)
        if let cachedCategoryCards = try? decoder.decode([String: [Card]].self, from: cardsData) {
            // Convert string keys back to Category enum
            allCardsByCategory = [:]
            for (categoryString, cards) in cachedCategoryCards {
                if let category = Category(rawValue: categoryString) {
                    allCardsByCategory[category] = cards
                }
            }

            let totalCards = allCardsByCategory.values.reduce(0) { $0 + $1.count }
            print("📦 Loaded \(totalCards) cards across \(allCardsByCategory.keys.count) categories from cache")
            return !allCardsByCategory.isEmpty
        }

        // Try old format (flat array) and migrate
        if let oldCards = try? decoder.decode([Card].self, from: cardsData) {
            print("🔄 Migrating old cache format to category-based format")

            // Organize old cards by category
            allCardsByCategory = [:]
            for card in oldCards {
                var categoryCards = allCardsByCategory[card.category] ?? []
                categoryCards.append(card)
                allCardsByCategory[card.category] = categoryCards
            }

            // Save in new format
            saveCategoryCards()

            let totalCards = allCardsByCategory.values.reduce(0) { $0 + $1.count }
            print("✅ Migrated \(totalCards) cards to new format")
            return !allCardsByCategory.isEmpty
        }

        print("❌ Unknown cache format")
        clearCache()
        return false
    }

    /// Save all category cards to cache
    private func saveCategoryCards() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601

            // Convert Category keys to strings for encoding
            var encodableDict: [String: [Card]] = [:]
            for (category, cards) in allCardsByCategory {
                encodableDict[category.rawValue] = cards
            }

            let cardsData = try encoder.encode(encodableDict)

            UserDefaults.standard.set(cardsData, forKey: cachedCardsKey)
            UserDefaults.standard.set(Date(), forKey: lastFetchDateKey)

            let totalCards = allCardsByCategory.values.reduce(0) { $0 + $1.count }
            print("💾 Cached \(totalCards) cards across \(allCardsByCategory.keys.count) categories")
        } catch {
            print("❌ Failed to cache cards: \(error)")
        }
    }

    /// Update cache after viewing a card
    private func updateCacheAfterViewing() {
        UserDefaults.standard.set(currentCardIndex, forKey: "currentCardIndex")
    }

    /// Clear all cached cards
    private func clearCache() {
        UserDefaults.standard.removeObject(forKey: cachedCardsKey)
        UserDefaults.standard.removeObject(forKey: lastFetchDateKey)
        UserDefaults.standard.removeObject(forKey: "currentCardIndex")
        UserDefaults.standard.removeObject(forKey: nextBatchCacheKey)
        print("🗑️ Cache cleared")
    }

    /// Cache next batch of cards
    private func cacheNextBatch(_ cards: [Card]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let cardsData = try encoder.encode(cards)

            UserDefaults.standard.set(cardsData, forKey: nextBatchCacheKey)
            print("💾 Cached next batch: \(cards.count) cards")
        } catch {
            print("❌ Failed to cache next batch: \(error)")
        }
    }

    /// Load next batch from cache
    private func loadNextBatchCache() -> [Card]? {
        guard let cardsData = UserDefaults.standard.data(forKey: nextBatchCacheKey) else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let cards = try decoder.decode([Card].self, from: cardsData)
            return cards
        } catch {
            print("❌ Failed to decode next batch cache: \(error)")
            return nil
        }
    }

    /// Clear next batch cache
    private func clearNextBatchCache() {
        UserDefaults.standard.removeObject(forKey: nextBatchCacheKey)
    }

    // MARK: - Position Persistence

    /// Save current card position to UserDefaults
    private func saveLastCardPosition() {
        UserDefaults.standard.set(currentCardIndex, forKey: lastCardIndexKey)
        print("💾 Saved card position: \(currentCardIndex)")
    }

    /// Save selected category to UserDefaults
    private func saveLastCategory() {
        if let category = selectedCategory {
            UserDefaults.standard.set(category.rawValue, forKey: lastCategoryKey)
            print("💾 Saved category: \(category.rawValue)")
        } else {
            UserDefaults.standard.removeObject(forKey: lastCategoryKey)
            print("💾 Cleared category (showing all)")
        }
    }

    /// Restore last card position from UserDefaults
    private func restoreLastCardPosition() {
        let savedIndex = UserDefaults.standard.integer(forKey: lastCardIndexKey)

        // For free users, ensure we don't restore to a position beyond their limit
        let maxAllowedIndex: Int
        if subscriptionManager.dailyCardLimit != nil {
            // Free user: can only be on cards they've already viewed
            maxAllowedIndex = min(savedIndex, subscriptionManager.cardsViewedToday - 1)
        } else {
            // Premium user: no restriction
            maxAllowedIndex = savedIndex
        }

        if maxAllowedIndex > 0 && maxAllowedIndex < cards.count {
            currentCardIndex = maxAllowedIndex
            if maxAllowedIndex != savedIndex {
                print("📥 Restored card position: \(maxAllowedIndex) (saved was \(savedIndex), adjusted for free tier)")
            } else {
                print("📥 Restored card position: \(maxAllowedIndex)")
            }
        } else if maxAllowedIndex == 0 || savedIndex == 0 {
            currentCardIndex = 0
            print("📥 Starting from first card")
        } else {
            print("⚠️ Saved index \(savedIndex) out of range (total: \(cards.count)), starting from 0")
            currentCardIndex = 0
        }
    }

    /// Restore last selected category from UserDefaults
    private func restoreLastCategory() {
        if let categoryString = UserDefaults.standard.string(forKey: lastCategoryKey),
           let category = Category(rawValue: categoryString) {
            selectedCategory = category
            print("📥 Restored category: \(category.rawValue)")
        } else {
            selectedCategory = nil
            print("📥 No saved category, showing all")
        }
    }
}
