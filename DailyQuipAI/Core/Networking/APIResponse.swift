//
//  APIResponse.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import Foundation

/// Standard API response wrapper
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
    let timestamp: Date

    enum CodingKeys: String, CodingKey {
        case success
        case data
        case message
        case timestamp
    }
}

/// Response for daily cards
struct DailyCardsResponse: Codable {
    let cards: [Card]
    let date: Date
    let totalAvailable: Int
}

/// Response for card list
struct CardListResponse: Codable {
    let cards: [Card]
    let total: Int
    let page: Int
    let limit: Int
}

/// Response for user creation/update
struct UserResponse: Codable {
    let user: User
    let token: String?
}

/// Response for quiz generation
struct QuizGenerationResponse: Codable {
    let questions: [QuizQuestion]
    let quizID: UUID
    let expiresAt: Date
}

/// Response for quiz submission
struct QuizSubmissionResponse: Codable {
    let result: QuizResult
    let rank: Int?
    let achievementsUnlocked: [Achievement]?
}

/// Response for quiz history
struct QuizHistoryResponse: Codable {
    let results: [QuizResult]
    let total: Int
    let statistics: QuizStatistics
}

/// Generic success response
struct SuccessResponse: Codable {
    let success: Bool
    let message: String
}
