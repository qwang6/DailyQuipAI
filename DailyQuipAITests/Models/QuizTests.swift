//
//  QuizTests.swift
//  DailyQuipAITests
//
//  Created by Claude on 10/4/25.
//

import XCTest
@testable import DailyQuipAI

final class QuizTests: XCTestCase {

    // MARK: - QuizQuestion Tests

    func testQuizQuestionCreation() {
        let question = QuizQuestion(
            id: UUID(),
            cardID: UUID(),
            questionText: "Test question?",
            type: .multipleChoice,
            options: ["A", "B", "C", "D"],
            correctAnswer: "B",
            explanation: "Test explanation"
        )

        XCTAssertEqual(question.questionText, "Test question?")
        XCTAssertEqual(question.type, .multipleChoice)
        XCTAssertEqual(question.options?.count, 4)
        XCTAssertEqual(question.correctAnswer, "B")
    }

    func testQuizQuestionIsCorrect() {
        let question = QuizQuestion(
            id: UUID(),
            cardID: UUID(),
            questionText: "Test?",
            type: .fillInBlank,
            options: nil,
            correctAnswer: "Florence",
            explanation: "Explanation"
        )

        // Case insensitive matching
        XCTAssertTrue(question.isCorrect("Florence"))
        XCTAssertTrue(question.isCorrect("florence"))
        XCTAssertTrue(question.isCorrect("FLORENCE"))

        // Whitespace trimming
        XCTAssertTrue(question.isCorrect("  Florence  "))

        // Wrong answers
        XCTAssertFalse(question.isCorrect("Rome"))
        XCTAssertFalse(question.isCorrect(""))
    }

    func testQuestionTypeDisplayNames() {
        XCTAssertEqual(QuestionType.multipleChoice.displayName, "Multiple Choice")
        XCTAssertEqual(QuestionType.trueFalse.displayName, "True/False")
        XCTAssertEqual(QuestionType.fillInBlank.displayName, "Fill in the Blank")
    }

    func testQuizQuestionCodable() throws {
        let question = QuizQuestion.mock()
        let encoder = JSONEncoder()
        let data = try encoder.encode(question)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(QuizQuestion.self, from: data)

        XCTAssertEqual(decoded.id, question.id)
        XCTAssertEqual(decoded.questionText, question.questionText)
        XCTAssertEqual(decoded.type, question.type)
    }

    func testQuizQuestionMockData() {
        let mcQuestion = QuizQuestion.mock(type: .multipleChoice)
        XCTAssertEqual(mcQuestion.type, .multipleChoice)
        XCTAssertNotNil(mcQuestion.options)
        XCTAssertEqual(mcQuestion.options?.count, 4)

        let tfQuestion = QuizQuestion.mock(type: .trueFalse)
        XCTAssertEqual(tfQuestion.type, .trueFalse)
        XCTAssertEqual(tfQuestion.options?.count, 2)

        let fibQuestion = QuizQuestion.mock(type: .fillInBlank)
        XCTAssertEqual(fibQuestion.type, .fillInBlank)
        XCTAssertNil(fibQuestion.options)
    }

    func testQuizQuestionMockArray() {
        let questions = QuizQuestion.mockArray(count: 6)
        XCTAssertEqual(questions.count, 6)

        // Should have different question types
        let types = Set(questions.map { $0.type })
        XCTAssertGreaterThan(types.count, 1)
    }

    // MARK: - QuizResult Tests

    func testQuizResultCreation() {
        let result = QuizResult(
            id: UUID(),
            quizType: .daily,
            score: 4,
            totalQuestions: 5,
            completedAt: Date(),
            wrongAnswers: [],
            timeSpent: 180
        )

        XCTAssertEqual(result.score, 4)
        XCTAssertEqual(result.totalQuestions, 5)
        XCTAssertEqual(result.timeSpent, 180)
    }

    func testQuizResultPercentage() {
        let result1 = QuizResult.mock(score: 5, totalQuestions: 5)
        XCTAssertEqual(result1.percentage, 100)

        let result2 = QuizResult.mock(score: 4, totalQuestions: 5)
        XCTAssertEqual(result2.percentage, 80)

        let result3 = QuizResult.mock(score: 3, totalQuestions: 5)
        XCTAssertEqual(result3.percentage, 60)

        let result4 = QuizResult.mock(score: 0, totalQuestions: 5)
        XCTAssertEqual(result4.percentage, 0)
    }

    func testQuizResultIsPerfect() {
        let perfectResult = QuizResult.mock(score: 5, totalQuestions: 5)
        XCTAssertTrue(perfectResult.isPerfect)

        let imperfectResult = QuizResult.mock(score: 4, totalQuestions: 5)
        XCTAssertFalse(imperfectResult.isPerfect)
    }

    func testQuizResultGrade() {
        let gradeA = QuizResult.mock(score: 5, totalQuestions: 5) // 100%
        XCTAssertEqual(gradeA.grade, "A")

        let gradeB = QuizResult.mock(score: 4, totalQuestions: 5) // 80%
        XCTAssertEqual(gradeB.grade, "B")

        let gradeC = QuizResult.mock(score: 7, totalQuestions: 10) // 70%
        XCTAssertEqual(gradeC.grade, "C")

        let gradeD = QuizResult.mock(score: 6, totalQuestions: 10) // 60%
        XCTAssertEqual(gradeD.grade, "D")

        let gradeF = QuizResult.mock(score: 2, totalQuestions: 5) // 40%
        XCTAssertEqual(gradeF.grade, "F")
    }

    func testQuizResultCodable() throws {
        let result = QuizResult.mock()
        let encoder = JSONEncoder()
        let data = try encoder.encode(result)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(QuizResult.self, from: data)

        XCTAssertEqual(decoded.id, result.id)
        XCTAssertEqual(decoded.score, result.score)
        XCTAssertEqual(decoded.totalQuestions, result.totalQuestions)
    }

    func testQuizTypeDisplayNames() {
        XCTAssertEqual(QuizType.daily.displayName, "Daily Challenge")
        XCTAssertEqual(QuizType.weekly.displayName, "Weekly Review")
        XCTAssertEqual(QuizType.category.displayName, "Category Quiz")
        XCTAssertEqual(QuizType.random.displayName, "Random Quiz")
    }
}
