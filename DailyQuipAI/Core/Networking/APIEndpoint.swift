//
//  APIEndpoint.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import Foundation

/// HTTP methods
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// API endpoints
enum APIEndpoint {
    // Card endpoints
    case dailyCards(categories: [Category])
    case card(id: UUID)
    case cardsByCategory(category: Category, limit: Int)

    // User endpoints
    case createUser(User)
    case getUser(id: UUID)
    case updateUser(User)
    case updateUserSettings(id: UUID, settings: UserSettings)

    // Quiz endpoints
    case generateQuiz(cardIDs: [UUID], count: Int)
    case submitQuizResult(QuizResult)
    case quizHistory(userID: UUID, limit: Int)

    // Path for the endpoint
    var path: String {
        switch self {
        case .dailyCards:
            return "/api/v1/cards/daily"
        case .card(let id):
            return "/api/v1/cards/\(id.uuidString)"
        case .cardsByCategory(let category, _):
            return "/api/v1/cards/category/\(category.rawValue.lowercased())"
        case .createUser:
            return "/api/v1/users"
        case .getUser(let id):
            return "/api/v1/users/\(id.uuidString)"
        case .updateUser(let user):
            return "/api/v1/users/\(user.id.uuidString)"
        case .updateUserSettings(let id, _):
            return "/api/v1/users/\(id.uuidString)/settings"
        case .generateQuiz:
            return "/api/v1/quiz/generate"
        case .submitQuizResult:
            return "/api/v1/quiz/results"
        case .quizHistory(let userID, _):
            return "/api/v1/quiz/results/\(userID.uuidString)"
        }
    }

    // HTTP method for the endpoint
    var method: HTTPMethod {
        switch self {
        case .dailyCards, .card, .cardsByCategory, .getUser, .quizHistory:
            return .get
        case .createUser, .generateQuiz, .submitQuizResult:
            return .post
        case .updateUser, .updateUserSettings:
            return .patch
        }
    }

    // Query parameters
    var queryItems: [URLQueryItem]? {
        switch self {
        case .dailyCards(let categories):
            let categoryString = categories.map { $0.rawValue }.joined(separator: ",")
            return [URLQueryItem(name: "categories", value: categoryString)]
        case .cardsByCategory(_, let limit):
            return [URLQueryItem(name: "limit", value: "\(limit)")]
        case .generateQuiz(_, let count):
            return [URLQueryItem(name: "count", value: "\(count)")]
        case .quizHistory(_, let limit):
            return [URLQueryItem(name: "limit", value: "\(limit)")]
        default:
            return nil
        }
    }

    // Request body (encodable)
    var body: Encodable? {
        switch self {
        case .createUser(let user):
            return user
        case .updateUser(let user):
            return user
        case .updateUserSettings(_, let settings):
            return settings
        case .generateQuiz(let cardIDs, _):
            return ["cardIDs": cardIDs]
        case .submitQuizResult(let result):
            return result
        default:
            return nil
        }
    }

    // Headers
    var headers: [String: String] {
        let headers = ["Content-Type": "application/json"]

        // Add authorization header if needed
        // headers["Authorization"] = "Bearer \(token)"

        return headers
    }
}
