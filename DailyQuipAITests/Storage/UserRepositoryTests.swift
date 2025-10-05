//
//  UserRepositoryTests.swift
//  DailyQuipAITests
//
//  Created by Claude on 10/4/25.
//

import XCTest
@testable import DailyQuipAI

final class UserRepositoryTests: XCTestCase {

    var repository: UserDefaultsUserRepository!
    var testDefaults: UserDefaults!

    override func setUp() async throws {
        testDefaults = UserDefaults(suiteName: "test.gleam.user")!
        repository = UserDefaultsUserRepository(defaults: testDefaults)
        testDefaults.removePersistentDomain(forName: "test.gleam.user")
    }

    override func tearDown() async throws {
        testDefaults.removePersistentDomain(forName: "test.gleam.user")
        testDefaults = nil
        repository = nil
    }

    func testSaveUser() async throws {
        let user = User.mock()

        try await repository.saveUser(user)

        let fetchedUser = try await repository.fetchUser()
        XCTAssertNotNil(fetchedUser)
        XCTAssertEqual(fetchedUser?.id, user.id)
        XCTAssertEqual(fetchedUser?.username, user.username)
    }

    func testFetchNonExistentUser() async throws {
        let user = try await repository.fetchUser()
        XCTAssertNil(user)
    }

    func testUpdateSettings() async throws {
        let user = User.mock()
        try await repository.saveUser(user)

        var newSettings = UserSettings.default
        newSettings.dailyGoal = 5
        newSettings.theme = .dark

        try await repository.updateSettings(newSettings)

        let fetchedUser = try await repository.fetchUser()
        XCTAssertEqual(fetchedUser?.settings.dailyGoal, 5)
        XCTAssertEqual(fetchedUser?.settings.theme, .dark)
    }

    func testUpdateSettingsWithoutUser() async throws {
        let settings = UserSettings.default

        do {
            try await repository.updateSettings(settings)
            XCTFail("Should throw userNotFound error")
        } catch let error as RepositoryError {
            XCTAssertEqual(error, RepositoryError.userNotFound)
        }
    }

    func testIncrementStreak() async throws {
        var user = User.mock(streak: 5)
        try await repository.saveUser(user)

        try await repository.incrementStreak()

        let fetchedUser = try await repository.fetchUser()
        XCTAssertEqual(fetchedUser?.streak, 6)
    }

    func testResetStreak() async throws {
        var user = User.mock(streak: 10)
        try await repository.saveUser(user)

        try await repository.resetStreak()

        let fetchedUser = try await repository.fetchUser()
        XCTAssertEqual(fetchedUser?.streak, 0)
    }

    func testIncrementCardsLearned() async throws {
        var user = User.mock(totalCardsLearned: 42)
        try await repository.saveUser(user)

        try await repository.incrementCardsLearned()

        let fetchedUser = try await repository.fetchUser()
        XCTAssertEqual(fetchedUser?.totalCardsLearned, 43)
    }

    func testDeleteUser() async throws {
        let user = User.mock()
        try await repository.saveUser(user)

        var fetchedUser = try await repository.fetchUser()
        XCTAssertNotNil(fetchedUser)

        try await repository.deleteUser()

        fetchedUser = try await repository.fetchUser()
        XCTAssertNil(fetchedUser)
    }

    func testMultipleUserUpdates() async throws {
        let user = User.mock(streak: 0, totalCardsLearned: 0)
        try await repository.saveUser(user)

        try await repository.incrementStreak()
        try await repository.incrementCardsLearned()
        try await repository.incrementStreak()
        try await repository.incrementCardsLearned()

        let fetchedUser = try await repository.fetchUser()
        XCTAssertEqual(fetchedUser?.streak, 2)
        XCTAssertEqual(fetchedUser?.totalCardsLearned, 2)
    }
}
