//
//  CardActionHandler.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import Foundation
import Combine

/// Handles card actions and side effects
@MainActor
class CardActionHandler: ObservableObject {

    private let cardRepository: CardRepository
    private let userRepository: UserRepository

    init(
        cardRepository: CardRepository,
        userRepository: UserRepository
    ) {
        self.cardRepository = cardRepository
        self.userRepository = userRepository
    }

    // MARK: - Card Actions

    /// Handle learn action - mark card as learned
    func handleLearn(card: Card) async throws {
        try await cardRepository.markCardAsLearned(id: card.id)
        try await updateUserStreak()
        HapticFeedback.light()
    }

    /// Handle save action - save card for later review
    func handleSave(card: Card) async throws {
        try await cardRepository.saveCard(card)
        HapticFeedback.success()
    }

    /// Handle share action - prepare card for sharing
    func handleShare(card: Card) -> ShareContent {
        HapticFeedback.light()

        let text = """
        \(card.title)

        \(card.backContent)

        Learned on DailyQuipAI - Daily Knowledge Cards
        """

        return ShareContent(
            text: text,
            url: card.frontImageURL
        )
    }

    /// Handle details action - get extended card information
    func handleDetails(card: Card) -> CardDetails {
        HapticFeedback.light()

        return CardDetails(
            card: card,
            relatedCards: [], // Future: fetch related cards
            references: [] // Future: fetch references
        )
    }

    // MARK: - Private Methods

    private func updateUserStreak() async throws {
        guard var user = try await userRepository.fetchUser() else {
            return
        }

        user.addCardLearned()
        try await userRepository.saveUser(user)
    }
}

// MARK: - Supporting Types

struct ShareContent {
    let text: String
    let url: URL
}

struct CardDetails {
    let card: Card
    let relatedCards: [Card]
    let references: [String]
}
