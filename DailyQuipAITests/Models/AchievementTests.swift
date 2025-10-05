//
//  AchievementTests.swift
//  DailyQuipAITests
//
//  Created by Claude on 10/4/25.
//

import XCTest
@testable import DailyQuipAI

final class AchievementTests: XCTestCase {

    func testAchievementCreationLocked() {
        let achievement = Achievement(type: .streak7)

        XCTAssertEqual(achievement.type, .streak7)
        XCTAssertEqual(achievement.title, "Week Warrior")
        XCTAssertFalse(achievement.isUnlocked)
        XCTAssertNil(achievement.unlockedAt)
    }

    func testAchievementCreationUnlocked() {
        let unlockDate = Date()
        let achievement = Achievement(type: .streak30, unlockedAt: unlockDate)

        XCTAssertEqual(achievement.type, .streak30)
        XCTAssertTrue(achievement.isUnlocked)
        XCTAssertNotNil(achievement.unlockedAt)
        XCTAssertEqual(achievement.unlockedAt, unlockDate)
    }

    func testAchievementTypeCount() {
        // Verify we have all expected achievement types
        let allTypes = AchievementType.allCases
        XCTAssertGreaterThanOrEqual(allTypes.count, 15)
    }

    func testStreakAchievements() {
        XCTAssertEqual(AchievementType.streak7.title, "Week Warrior")
        XCTAssertEqual(AchievementType.streak30.title, "Monthly Master")
        XCTAssertEqual(AchievementType.streak100.title, "Hundred Day Hero")
        XCTAssertEqual(AchievementType.streak365.title, "Year-Long Learner")
    }

    func testCardsAchievements() {
        XCTAssertEqual(AchievementType.cards50.title, "Half Century")
        XCTAssertEqual(AchievementType.cards100.title, "Century Club")
        XCTAssertEqual(AchievementType.cards365.title, "Daily Learner")
        XCTAssertEqual(AchievementType.cards1000.title, "Knowledge Collector")
    }

    func testAchievementDescriptions() {
        for type in AchievementType.allCases {
            XCTAssertFalse(type.description.isEmpty, "\(type.rawValue) should have a description")
        }
    }

    func testAchievementIcons() {
        for type in AchievementType.allCases {
            XCTAssertFalse(type.iconName.isEmpty, "\(type.rawValue) should have an icon")
        }
    }

    func testAchievementCodable() throws {
        let achievement = Achievement(type: .perfectQuiz, unlockedAt: Date())
        let encoder = JSONEncoder()
        let data = try encoder.encode(achievement)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Achievement.self, from: data)

        XCTAssertEqual(decoded.id, achievement.id)
        XCTAssertEqual(decoded.type, achievement.type)
        XCTAssertEqual(decoded.isUnlocked, achievement.isUnlocked)
    }

    func testAchievementMockData() {
        let lockedAchievement = Achievement.mock(isUnlocked: false)
        XCTAssertFalse(lockedAchievement.isUnlocked)

        let unlockedAchievement = Achievement.mock(isUnlocked: true)
        XCTAssertTrue(unlockedAchievement.isUnlocked)
    }

    func testAchievementMockArray() {
        let achievements = Achievement.mockArray(count: 5)
        XCTAssertEqual(achievements.count, 5)

        // First 3 should be unlocked per mock implementation
        XCTAssertTrue(achievements[0].isUnlocked)
        XCTAssertTrue(achievements[1].isUnlocked)
        XCTAssertTrue(achievements[2].isUnlocked)
        XCTAssertFalse(achievements[3].isUnlocked)
        XCTAssertFalse(achievements[4].isUnlocked)
    }
}
