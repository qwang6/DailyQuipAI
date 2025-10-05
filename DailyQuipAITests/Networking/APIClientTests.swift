//
//  APIClientTests.swift
//  DailyQuipAITests
//
//  Created by Claude on 10/4/25.
//

import XCTest
@testable import DailyQuipAI

final class APIClientTests: XCTestCase {

    var mockClient: MockAPIClient!

    override func setUp() async throws {
        mockClient = MockAPIClient()
    }

    override func tearDown() async throws {
        mockClient = nil
    }

    func testSuccessfulRequest() async throws {
        // Setup mock response
        let mockCards = Card.mockArray(count: 3)
        let response = DailyCardsResponse(
            cards: mockCards,
            date: Date(),
            totalAvailable: 3
        )
        try mockClient.setMockResponse(response)

        // Make request
        let result: DailyCardsResponse = try await mockClient.request(.dailyCards(categories: [.history]))

        // Verify
        XCTAssertEqual(result.cards.count, 3)
        XCTAssertEqual(result.totalAvailable, 3)
    }

    func testRequestWithError() async throws {
        mockClient.shouldFail = true
        mockClient.mockError = NetworkError.serverError(statusCode: 500, message: "Server error")

        do {
            let _: DailyCardsResponse = try await mockClient.request(.dailyCards(categories: [.history]))
            XCTFail("Should have thrown an error")
        } catch let error as NetworkError {
            if case .serverError(let statusCode, _) = error {
                XCTAssertEqual(statusCode, 500)
            } else {
                XCTFail("Wrong error type")
            }
        }
    }

    func testRequestWithDelay() async throws {
        mockClient.delay = 0.1 // 100ms delay
        let mockCard = Card.mock()
        try mockClient.setMockResponse(mockCard)

        let startTime = Date()
        let _: Card = try await mockClient.request(.card(id: mockCard.id))
        let elapsed = Date().timeIntervalSince(startTime)

        XCTAssertGreaterThanOrEqual(elapsed, 0.1)
    }

    func testNetworkUnavailableError() async throws {
        mockClient.shouldFail = true
        mockClient.mockError = NetworkError.networkUnavailable

        do {
            let _: Card = try await mockClient.request(.card(id: UUID()))
            XCTFail("Should have thrown network unavailable error")
        } catch let error as NetworkError {
            XCTAssertEqual(error.localizedDescription, "Network unavailable. Please check your connection.")
        }
    }

    func testUnauthorizedError() async throws {
        mockClient.shouldFail = true
        mockClient.mockError = NetworkError.unauthorized

        do {
            let _: User = try await mockClient.request(.getUser(id: UUID()))
            XCTFail("Should have thrown unauthorized error")
        } catch let error as NetworkError {
            if case .unauthorized = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Wrong error type")
            }
        }
    }

    func testDecodingError() async throws {
        // Set invalid JSON data
        mockClient.mockData = "invalid json".data(using: .utf8)

        do {
            let _: Card = try await mockClient.request(.card(id: UUID()))
            XCTFail("Should have thrown decoding error")
        } catch let error as NetworkError {
            if case .decodingError = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        }
    }

    func testMultipleRequests() async throws {
        let card1 = Card.mock()
        let card2 = Card.mock()

        // First request
        try mockClient.setMockResponse(card1)
        let result1: Card = try await mockClient.request(.card(id: card1.id))
        XCTAssertEqual(result1.id, card1.id)

        // Second request with different data
        try mockClient.setMockResponse(card2)
        let result2: Card = try await mockClient.request(.card(id: card2.id))
        XCTAssertEqual(result2.id, card2.id)
    }
}
