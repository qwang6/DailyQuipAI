//
//  UserTests.swift
//  DailyQuipAITests
//
//  Created by Claude on 10/4/25.
//

import XCTest
@testable import DailyQuipAI

final class UserTests: XCTestCase {

    func testUserCreation() {
        let user = User(
            id: UUID(),
            username: "TestUser",
            email: "test@example.com",
            interests: [.history, .science],
            streak: 0,
            totalCardsLearned: 0,
            settings: .default,
            createdAt: Date()
        )

        XCTAssertEqual(user.username, "TestUser")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.interests.count, 2)
        XCTAssertEqual(user.streak, 0)
    }

    func testIncrementStreak() {
        var user = User.mock(streak: 5)
        XCTAssertEqual(user.streak, 5)

        user.incrementStreak()
        XCTAssertEqual(user.streak, 6)

        user.incrementStreak()
        XCTAssertEqual(user.streak, 7)
    }

    func testResetStreak() {
        var user = User.mock(streak: 10)
        XCTAssertEqual(user.streak, 10)

        user.resetStreak()
        XCTAssertEqual(user.streak, 0)
    }

    func testAddCardLearned() {
        var user = User.mock(totalCardsLearned: 50)
        XCTAssertEqual(user.totalCardsLearned, 50)

        user.addCardLearned()
        XCTAssertEqual(user.totalCardsLearned, 51)
    }

    func testHasActiveStreak() {
        var user = User.mock(streak: 0)
        XCTAssertFalse(user.hasActiveStreak)

        user.incrementStreak()
        XCTAssertTrue(user.hasActiveStreak)
    }

    func testStreakMilestone() {
        var user = User.mock(streak: 5)
        XCTAssertNil(user.streakMilestone)

        user = User.mock(streak: 7)
        XCTAssertEqual(user.streakMilestone, 7)

        user = User.mock(streak: 50)
        XCTAssertEqual(user.streakMilestone, 30)

        user = User.mock(streak: 200)
        XCTAssertEqual(user.streakMilestone, 100)

        user = User.mock(streak: 400)
        XCTAssertEqual(user.streakMilestone, 365)
    }

    func testUserCodable() throws {
        let user = User.mock()
        let encoder = JSONEncoder()
        let data = try encoder.encode(user)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(User.self, from: data)

        XCTAssertEqual(decoded.id, user.id)
        XCTAssertEqual(decoded.username, user.username)
        XCTAssertEqual(decoded.email, user.email)
        XCTAssertEqual(decoded.streak, user.streak)
    }

    func testUserSettingsDefault() {
        let settings = UserSettings.default

        XCTAssertTrue(settings.notificationEnabled)
        XCTAssertEqual(settings.theme, .system)
        XCTAssertEqual(settings.dailyGoal, 3)

        // Verify notification time is set to 8 AM
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: settings.notificationTime)
        XCTAssertEqual(components.hour, 8)
        XCTAssertEqual(components.minute, 0)
    }

    func testThemeEnum() {
        XCTAssertEqual(Theme.system.displayName, "System")
        XCTAssertEqual(Theme.light.displayName, "Light")
        XCTAssertEqual(Theme.dark.displayName, "Dark")
    }

    func testThemeCodable() throws {
        let theme = Theme.dark
        let encoder = JSONEncoder()
        let data = try encoder.encode(theme)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Theme.self, from: data)
        XCTAssertEqual(decoded, theme)
    }
}
