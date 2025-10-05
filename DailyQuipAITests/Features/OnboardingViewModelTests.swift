//
//  OnboardingViewModelTests.swift
//  DailyQuipAITests
//
//  Created by Claude on 10/4/25.
//

import XCTest
@testable import DailyQuipAI

final class OnboardingViewModelTests: XCTestCase {

    var viewModel: OnboardingViewModel!

    override func setUp() {
        super.setUp()
        viewModel = OnboardingViewModel()
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "selectedCategories")
        UserDefaults.standard.removeObject(forKey: "dailyGoal")
    }

    override func tearDown() {
        viewModel = nil
        // Clean up UserDefaults
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "selectedCategories")
        UserDefaults.standard.removeObject(forKey: "dailyGoal")
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertEqual(viewModel.currentStep, .welcome)
        XCTAssertTrue(viewModel.selectedCategories.isEmpty)
        XCTAssertEqual(viewModel.dailyGoal, 5)
    }

    // MARK: - Navigation Tests

    func testGoToNextStepFromWelcome() {
        viewModel.currentStep = .welcome
        viewModel.goToNextStep()
        XCTAssertEqual(viewModel.currentStep, .categorySelection)
    }

    func testGoToNextStepFromCategorySelection() {
        viewModel.currentStep = .categorySelection
        viewModel.goToNextStep()
        XCTAssertEqual(viewModel.currentStep, .learningGoal)
    }

    func testGoToNextStepFromLearningGoal() {
        viewModel.currentStep = .learningGoal
        viewModel.goToNextStep()
        XCTAssertEqual(viewModel.currentStep, .notificationPermission)
    }

    func testGoToNextStepFromNotificationPermission() {
        viewModel.currentStep = .notificationPermission
        viewModel.goToNextStep()
        // Should remain on same step
        XCTAssertEqual(viewModel.currentStep, .notificationPermission)
    }

    // MARK: - Category Selection Tests

    func testCategorySelection() {
        viewModel.selectedCategories.insert(.science)
        viewModel.selectedCategories.insert(.history)

        XCTAssertEqual(viewModel.selectedCategories.count, 2)
        XCTAssertTrue(viewModel.selectedCategories.contains(.science))
        XCTAssertTrue(viewModel.selectedCategories.contains(.history))
    }

    func testCategoryDeselection() {
        viewModel.selectedCategories.insert(.science)
        viewModel.selectedCategories.remove(.science)

        XCTAssertTrue(viewModel.selectedCategories.isEmpty)
    }

    // MARK: - Daily Goal Tests

    func testDailyGoalChange() {
        viewModel.dailyGoal = 10
        XCTAssertEqual(viewModel.dailyGoal, 10)
    }

    // MARK: - Completion Tests

    func testCompleteOnboarding() {
        // Setup
        viewModel.selectedCategories = [.science, .history, .art]
        viewModel.dailyGoal = 10

        // Listen for notification
        let expectation = XCTestExpectation(description: "Onboarding completed notification")
        let observer = NotificationCenter.default.addObserver(
            forName: .onboardingCompleted,
            object: nil,
            queue: .main
        ) { _ in
            expectation.fulfill()
        }

        // Complete onboarding
        viewModel.completeOnboarding()

        // Verify UserDefaults
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "hasCompletedOnboarding"))

        let savedCategories = UserDefaults.standard.stringArray(forKey: "selectedCategories")
        XCTAssertEqual(savedCategories?.count, 3)
        XCTAssertTrue(savedCategories?.contains("Science") ?? false)
        XCTAssertTrue(savedCategories?.contains("History") ?? false)
        XCTAssertTrue(savedCategories?.contains("Art") ?? false)

        let savedGoal = UserDefaults.standard.integer(forKey: "dailyGoal")
        XCTAssertEqual(savedGoal, 10)

        // Wait for notification
        wait(for: [expectation], timeout: 1.0)

        NotificationCenter.default.removeObserver(observer)
    }

    func testCompleteOnboardingWithNoCategories() {
        // Setup with empty categories
        viewModel.selectedCategories = []
        viewModel.dailyGoal = 5

        // Complete onboarding
        viewModel.completeOnboarding()

        // Verify UserDefaults
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "hasCompletedOnboarding"))

        let savedCategories = UserDefaults.standard.stringArray(forKey: "selectedCategories")
        XCTAssertTrue(savedCategories?.isEmpty ?? true)

        let savedGoal = UserDefaults.standard.integer(forKey: "dailyGoal")
        XCTAssertEqual(savedGoal, 5)
    }
}
