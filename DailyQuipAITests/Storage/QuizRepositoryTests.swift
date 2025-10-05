//
//  QuizRepositoryTests.swift
//  DailyQuipAITests
//
//  Created by Claude on 10/4/25.
//

import XCTest
@testable import DailyQuipAI

final class QuizRepositoryTests: XCTestCase {

    var repository: UserDefaultsQuizRepository!
    var testDefaults: UserDefaults!

    override func setUp() async throws {
        testDefaults = UserDefaults(suiteName: "test.gleam.quiz")!
        repository = UserDefaultsQuizRepository(defaults: testDefaults)
        testDefaults.removePersistentDomain(forName: "test.gleam.quiz")
    }

    override func tearDown() async throws {
        testDefaults.removePersistentDomain(forName: "test.gleam.quiz")
        testDefaults = nil
        repository = nil
    }

    func testGenerateQuestions() async throws {
        let cards = Card.mockArray(count: 10)

        let questions = try await repository.generateQuestions(from: cards)

        XCTAssertEqual(questions.count, 5) // Should generate 5 questions
        XCTAssertFalse(questions.isEmpty)
    }

    func testGenerateQuestionsFromFewCards() async throws {
        let cards = Card.mockArray(count: 2)

        let questions = try await repository.generateQuestions(from: cards)

        XCTAssertEqual(questions.count, 2) // Should only generate 2 if only 2 cards available
    }

    func testSaveQuizResult() async throws {
        let result = QuizResult.mock(score: 4, totalQuestions: 5)

        try await repository.saveQuizResult(result)

        let results = try await repository.fetchQuizResults(limit: 10)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.id, result.id)
    }

    func testFetchQuizResultsLimit() async throws {
        // Save 10 quiz results
        for i in 1...10 {
            let result = QuizResult(
                id: UUID(),
                quizType: .daily,
                score: i,
                totalQuestions: 5,
                completedAt: Date(),
                wrongAnswers: [], // No wrong answers for this test
                timeSpent: 180
            )
            try await repository.saveQuizResult(result)
        }

        let results = try await repository.fetchQuizResults(limit: 5)
        XCTAssertGreaterThanOrEqual(results.count, 5) // At least 5
        XCTAssertLessThanOrEqual(results.count, 5) // At most 5
    }

    func testFetchQuizResultsOrder() async throws {
        let result1 = QuizResult.mock(score: 3, totalQuestions: 5)
        let result2 = QuizResult.mock(score: 4, totalQuestions: 5)

        try await repository.saveQuizResult(result1)
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        try await repository.saveQuizResult(result2)

        let results = try await repository.fetchQuizResults(limit: 10)
        XCTAssertEqual(results.count, 2)
        // Most recent should be first
        XCTAssertEqual(results.first?.id, result2.id)
    }

    func testSaveWrongAnswers() async throws {
        let wrongQuestion = QuizQuestion.mock()
        let result = QuizResult(
            id: UUID(),
            quizType: .daily,
            score: 4,
            totalQuestions: 5,
            completedAt: Date(),
            wrongAnswers: [wrongQuestion],
            timeSpent: 180
        )

        try await repository.saveQuizResult(result)

        let wrongAnswers = try await repository.fetchWrongAnswers()
        XCTAssertEqual(wrongAnswers.count, 1)
        XCTAssertEqual(wrongAnswers.first?.id, wrongQuestion.id)
    }

    func testMarkAnswerAsLearned() async throws {
        let wrongQuestion = QuizQuestion.mock()
        let result = QuizResult(
            id: UUID(),
            quizType: .daily,
            score: 4,
            totalQuestions: 5,
            completedAt: Date(),
            wrongAnswers: [wrongQuestion],
            timeSpent: 180
        )

        try await repository.saveQuizResult(result)

        var wrongAnswers = try await repository.fetchWrongAnswers()
        XCTAssertEqual(wrongAnswers.count, 1)

        try await repository.markAnswerAsLearned(questionID: wrongQuestion.id)

        wrongAnswers = try await repository.fetchWrongAnswers()
        XCTAssertEqual(wrongAnswers.count, 0)
    }

    func testFetchQuizStatistics() async throws {
        // Save some quiz results
        let result1 = QuizResult.mock(score: 5, totalQuestions: 5) // Perfect
        let result2 = QuizResult.mock(score: 4, totalQuestions: 5)
        let result3 = QuizResult.mock(score: 3, totalQuestions: 5)

        try await repository.saveQuizResult(result1)
        try await repository.saveQuizResult(result2)
        try await repository.saveQuizResult(result3)

        let stats = try await repository.fetchQuizStatistics()

        XCTAssertEqual(stats.totalQuizzesTaken, 3)
        XCTAssertEqual(stats.perfectScoresCount, 1)
        XCTAssertEqual(stats.totalQuestionsAnswered, 15)
        XCTAssertEqual(stats.totalCorrectAnswers, 12)
        XCTAssertEqual(stats.averageScore, 80.0, accuracy: 0.1) // 12/15 = 80%
    }

    func testFetchQuizStatisticsEmpty() async throws {
        let stats = try await repository.fetchQuizStatistics()

        XCTAssertEqual(stats.totalQuizzesTaken, 0)
        XCTAssertEqual(stats.perfectScoresCount, 0)
        XCTAssertEqual(stats.averageScore, 0)
    }
}
