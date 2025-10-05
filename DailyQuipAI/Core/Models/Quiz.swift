//
//  Quiz.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import Foundation

/// A quiz question based on card content
struct QuizQuestion: Identifiable, Codable, Equatable {
    let id: UUID
    let cardID: UUID
    let questionText: String
    let type: QuestionType
    let options: [String]? // For multiple choice questions
    let correctAnswer: String
    let explanation: String

    /// Check if provided answer is correct
    func isCorrect(_ answer: String) -> Bool {
        correctAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            == answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Types of quiz questions
enum QuestionType: String, Codable, CaseIterable {
    case multipleChoice = "multiple_choice"
    case trueFalse = "true_false"
    case fillInBlank = "fill_in_blank"

    var displayName: String {
        switch self {
        case .multipleChoice: return "Multiple Choice"
        case .trueFalse: return "True/False"
        case .fillInBlank: return "Fill in the Blank"
        }
    }
}

/// Result of a completed quiz
struct QuizResult: Identifiable, Codable, Equatable {
    let id: UUID
    let quizType: QuizType
    let score: Int
    let totalQuestions: Int
    let completedAt: Date
    let wrongAnswers: [QuizQuestion]
    let timeSpent: TimeInterval // in seconds

    var percentage: Int {
        guard totalQuestions > 0 else { return 0 }
        return Int((Double(score) / Double(totalQuestions)) * 100)
    }

    var isPerfect: Bool {
        score == totalQuestions
    }

    var grade: String {
        switch percentage {
        case 90...100: return "A"
        case 80..<90: return "B"
        case 70..<80: return "C"
        case 60..<70: return "D"
        default: return "F"
        }
    }
}

/// Types of quizzes
enum QuizType: String, Codable {
    case daily = "daily"
    case weekly = "weekly"
    case category = "category"
    case random = "random"

    var displayName: String {
        switch self {
        case .daily: return "Daily Challenge"
        case .weekly: return "Weekly Review"
        case .category: return "Category Quiz"
        case .random: return "Random Quiz"
        }
    }
}

// MARK: - Mock Data for Testing
#if DEBUG
extension QuizQuestion {
    static func mock(
        id: UUID = UUID(),
        type: QuestionType = .multipleChoice
    ) -> QuizQuestion {
        switch type {
        case .multipleChoice:
            return QuizQuestion(
                id: id,
                cardID: UUID(),
                questionText: "When did the Renaissance begin?",
                type: .multipleChoice,
                options: [
                    "12th century",
                    "14th century",
                    "16th century",
                    "18th century"
                ],
                correctAnswer: "14th century",
                explanation: "The Renaissance began in Italy during the 14th century and spread across Europe."
            )
        case .trueFalse:
            return QuizQuestion(
                id: id,
                cardID: UUID(),
                questionText: "Leonardo da Vinci was a Renaissance artist.",
                type: .trueFalse,
                options: ["True", "False"],
                correctAnswer: "True",
                explanation: "Leonardo da Vinci was one of the most famous Renaissance artists and inventors."
            )
        case .fillInBlank:
            return QuizQuestion(
                id: id,
                cardID: UUID(),
                questionText: "The Renaissance began in _____, Italy.",
                type: .fillInBlank,
                options: nil,
                correctAnswer: "Florence",
                explanation: "Florence was the birthplace of the Renaissance, home to the Medici family and many great artists."
            )
        }
    }

    static func mockArray(count: Int = 5) -> [QuizQuestion] {
        let types = QuestionType.allCases
        return (0..<count).map { index in
            QuizQuestion.mock(type: types[index % types.count])
        }
    }
}

extension QuizResult {
    static func mock(
        score: Int = 4,
        totalQuestions: Int = 5
    ) -> QuizResult {
        QuizResult(
            id: UUID(),
            quizType: .daily,
            score: score,
            totalQuestions: totalQuestions,
            completedAt: Date(),
            wrongAnswers: QuizQuestion.mockArray(count: totalQuestions - score),
            timeSpent: 180 // 3 minutes
        )
    }
}
#endif
