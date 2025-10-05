//
//  QuizRepository.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import Foundation

/// Protocol for quiz data access
protocol QuizRepository {
    /// Generate quiz questions from cards
    /// - Parameter cards: The cards to generate questions from
    /// - Returns: Array of quiz questions
    func generateQuestions(from cards: [Card]) async throws -> [QuizQuestion]

    /// Save a quiz result
    /// - Parameter result: The quiz result to save
    func saveQuizResult(_ result: QuizResult) async throws

    /// Fetch quiz history
    /// - Parameter limit: Maximum number of results to fetch
    /// - Returns: Array of quiz results, most recent first
    func fetchQuizResults(limit: Int) async throws -> [QuizResult]

    /// Fetch all wrong answers across all quizzes
    /// - Returns: Array of questions answered incorrectly
    func fetchWrongAnswers() async throws -> [QuizQuestion]

    /// Mark a wrong answer as learned (remove from wrong answers)
    /// - Parameter questionID: The question ID
    func markAnswerAsLearned(questionID: UUID) async throws

    /// Get quiz statistics
    /// - Returns: Total quizzes taken, average score, perfect scores count
    func fetchQuizStatistics() async throws -> QuizStatistics
}

/// Quiz statistics summary
struct QuizStatistics: Codable {
    let totalQuizzesTaken: Int
    let averageScore: Double
    let perfectScoresCount: Int
    let totalQuestionsAnswered: Int
    let totalCorrectAnswers: Int
}

/// UserDefaults-based implementation of QuizRepository
class UserDefaultsQuizRepository: QuizRepository {

    private let quizResultsKey = "gleam.quizResults"
    private let wrongAnswersKey = "gleam.wrongAnswers"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func generateQuestions(from cards: [Card]) async throws -> [QuizQuestion] {
        // Simple implementation: generate one question per card
        // In production, this would use more sophisticated logic
        return cards.prefix(5).map { card in
            QuizQuestion(
                id: UUID(),
                cardID: card.id,
                questionText: "What category is '\(card.title)' from?",
                type: .multipleChoice,
                options: Category.allCases.shuffled().prefix(4).map { $0.rawValue },
                correctAnswer: card.category.rawValue,
                explanation: "This card belongs to the \(card.category.rawValue) category."
            )
        }
    }

    func saveQuizResult(_ result: QuizResult) async throws {
        var results = try await fetchQuizResults(limit: 100)
        results.insert(result, at: 0) // Most recent first

        // Save wrong answers
        if !result.wrongAnswers.isEmpty {
            var wrongAnswers = try await fetchWrongAnswers()
            wrongAnswers.append(contentsOf: result.wrongAnswers)
            try saveWrongAnswers(wrongAnswers)
        }

        try saveQuizResults(results)
    }

    func fetchQuizResults(limit: Int = 100) async throws -> [QuizResult] {
        guard let data = defaults.data(forKey: quizResultsKey) else {
            return []
        }

        let decoder = JSONDecoder()
        let allResults = try decoder.decode([QuizResult].self, from: data)
        return Array(allResults.prefix(limit))
    }

    func fetchWrongAnswers() async throws -> [QuizQuestion] {
        guard let data = defaults.data(forKey: wrongAnswersKey) else {
            return []
        }

        let decoder = JSONDecoder()
        return try decoder.decode([QuizQuestion].self, from: data)
    }

    func markAnswerAsLearned(questionID: UUID) async throws {
        var wrongAnswers = try await fetchWrongAnswers()
        wrongAnswers.removeAll { $0.id == questionID }
        try saveWrongAnswers(wrongAnswers)
    }

    func fetchQuizStatistics() async throws -> QuizStatistics {
        let results = try await fetchQuizResults(limit: 1000)

        let totalQuizzes = results.count
        let totalQuestionsAnswered = results.reduce(0) { $0 + $1.totalQuestions }
        let totalCorrectAnswers = results.reduce(0) { $0 + $1.score }
        let averageScore = totalQuizzes > 0
            ? Double(totalCorrectAnswers) / Double(totalQuestionsAnswered) * 100
            : 0
        let perfectScores = results.filter { $0.isPerfect }.count

        return QuizStatistics(
            totalQuizzesTaken: totalQuizzes,
            averageScore: averageScore,
            perfectScoresCount: perfectScores,
            totalQuestionsAnswered: totalQuestionsAnswered,
            totalCorrectAnswers: totalCorrectAnswers
        )
    }

    // MARK: - Private Helpers

    private func saveQuizResults(_ results: [QuizResult]) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(results)
        defaults.set(data, forKey: quizResultsKey)
    }

    private func saveWrongAnswers(_ answers: [QuizQuestion]) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(answers)
        defaults.set(data, forKey: wrongAnswersKey)
    }
}

// MARK: - Mock Repository for Testing
#if DEBUG
class MockQuizRepository: QuizRepository {
    var quizResults: [QuizResult] = []
    var wrongAnswers: [QuizQuestion] = []
    var shouldThrowError = false

    func generateQuestions(from cards: [Card]) async throws -> [QuizQuestion] {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        return QuizQuestion.mockArray(count: min(5, cards.count))
    }

    func saveQuizResult(_ result: QuizResult) async throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        quizResults.insert(result, at: 0)
        wrongAnswers.append(contentsOf: result.wrongAnswers)
    }

    func fetchQuizResults(limit: Int) async throws -> [QuizResult] {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        return Array(quizResults.prefix(limit))
    }

    func fetchWrongAnswers() async throws -> [QuizQuestion] {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        return wrongAnswers
    }

    func markAnswerAsLearned(questionID: UUID) async throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        wrongAnswers.removeAll { $0.id == questionID }
    }

    func fetchQuizStatistics() async throws -> QuizStatistics {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }

        let totalQuizzes = quizResults.count
        let totalQuestionsAnswered = quizResults.reduce(0) { $0 + $1.totalQuestions }
        let totalCorrectAnswers = quizResults.reduce(0) { $0 + $1.score }
        let averageScore = totalQuizzes > 0
            ? Double(totalCorrectAnswers) / Double(totalQuestionsAnswered) * 100
            : 0
        let perfectScores = quizResults.filter { $0.isPerfect }.count

        return QuizStatistics(
            totalQuizzesTaken: totalQuizzes,
            averageScore: averageScore,
            perfectScoresCount: perfectScores,
            totalQuestionsAnswered: totalQuestionsAnswered,
            totalCorrectAnswers: totalCorrectAnswers
        )
    }
}
#endif
