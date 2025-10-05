//
//  APIEndpointTests.swift
//  DailyQuipAITests
//
//  Created by Claude on 10/4/25.
//

import XCTest
@testable import DailyQuipAI

final class APIEndpointTests: XCTestCase {

    func testDailyCardsEndpoint() {
        let endpoint = APIEndpoint.dailyCards(categories: [.history, .science])

        XCTAssertEqual(endpoint.path, "/api/v1/cards/daily")
        XCTAssertEqual(endpoint.method, .get)
        XCTAssertNotNil(endpoint.queryItems)

        // Check query items
        let categoryItem = endpoint.queryItems?.first { $0.name == "categories" }
        XCTAssertNotNil(categoryItem)
        XCTAssertTrue(categoryItem?.value?.contains("History") ?? false)
        XCTAssertTrue(categoryItem?.value?.contains("Science") ?? false)
    }

    func testCardEndpoint() {
        let id = UUID()
        let endpoint = APIEndpoint.card(id: id)

        XCTAssertEqual(endpoint.path, "/api/v1/cards/\(id.uuidString)")
        XCTAssertEqual(endpoint.method, .get)
        XCTAssertNil(endpoint.queryItems)
    }

    func testCardsByCategoryEndpoint() {
        let endpoint = APIEndpoint.cardsByCategory(category: .history, limit: 10)

        XCTAssertEqual(endpoint.path, "/api/v1/cards/category/history")
        XCTAssertEqual(endpoint.method, .get)

        let limitItem = endpoint.queryItems?.first { $0.name == "limit" }
        XCTAssertEqual(limitItem?.value, "10")
    }

    func testCreateUserEndpoint() {
        let user = User.mock()
        let endpoint = APIEndpoint.createUser(user)

        XCTAssertEqual(endpoint.path, "/api/v1/users")
        XCTAssertEqual(endpoint.method, .post)
        XCTAssertNotNil(endpoint.body)
    }

    func testGetUserEndpoint() {
        let id = UUID()
        let endpoint = APIEndpoint.getUser(id: id)

        XCTAssertEqual(endpoint.path, "/api/v1/users/\(id.uuidString)")
        XCTAssertEqual(endpoint.method, .get)
    }

    func testUpdateUserEndpoint() {
        let user = User.mock()
        let endpoint = APIEndpoint.updateUser(user)

        XCTAssertEqual(endpoint.path, "/api/v1/users/\(user.id.uuidString)")
        XCTAssertEqual(endpoint.method, .patch)
        XCTAssertNotNil(endpoint.body)
    }

    func testUpdateUserSettingsEndpoint() {
        let id = UUID()
        let settings = UserSettings.default
        let endpoint = APIEndpoint.updateUserSettings(id: id, settings: settings)

        XCTAssertEqual(endpoint.path, "/api/v1/users/\(id.uuidString)/settings")
        XCTAssertEqual(endpoint.method, .patch)
        XCTAssertNotNil(endpoint.body)
    }

    func testGenerateQuizEndpoint() {
        let cardIDs = [UUID(), UUID(), UUID()]
        let endpoint = APIEndpoint.generateQuiz(cardIDs: cardIDs, count: 5)

        XCTAssertEqual(endpoint.path, "/api/v1/quiz/generate")
        XCTAssertEqual(endpoint.method, .post)

        let countItem = endpoint.queryItems?.first { $0.name == "count" }
        XCTAssertEqual(countItem?.value, "5")
    }

    func testSubmitQuizResultEndpoint() {
        let result = QuizResult.mock()
        let endpoint = APIEndpoint.submitQuizResult(result)

        XCTAssertEqual(endpoint.path, "/api/v1/quiz/results")
        XCTAssertEqual(endpoint.method, .post)
        XCTAssertNotNil(endpoint.body)
    }

    func testQuizHistoryEndpoint() {
        let userID = UUID()
        let endpoint = APIEndpoint.quizHistory(userID: userID, limit: 20)

        XCTAssertEqual(endpoint.path, "/api/v1/quiz/results/\(userID.uuidString)")
        XCTAssertEqual(endpoint.method, .get)

        let limitItem = endpoint.queryItems?.first { $0.name == "limit" }
        XCTAssertEqual(limitItem?.value, "20")
    }

    func testEndpointHeaders() {
        let endpoint = APIEndpoint.dailyCards(categories: [.history])
        let headers = endpoint.headers

        XCTAssertEqual(headers["Content-Type"], "application/json")
        XCTAssertFalse(headers.isEmpty)
    }

    func testHTTPMethods() {
        XCTAssertEqual(HTTPMethod.get.rawValue, "GET")
        XCTAssertEqual(HTTPMethod.post.rawValue, "POST")
        XCTAssertEqual(HTTPMethod.put.rawValue, "PUT")
        XCTAssertEqual(HTTPMethod.patch.rawValue, "PATCH")
        XCTAssertEqual(HTTPMethod.delete.rawValue, "DELETE")
    }
}
