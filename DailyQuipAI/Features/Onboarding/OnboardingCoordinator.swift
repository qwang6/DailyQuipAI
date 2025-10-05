//
//  OnboardingCoordinator.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import SwiftUI
import Combine

/// Onboarding flow coordinator
struct OnboardingCoordinator: View {
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        ZStack {
            switch viewModel.currentStep {
            case .welcome:
                OnboardingWelcomeView {
                    viewModel.goToNextStep()
                }
                .transition(.opacity)

            case .categorySelection:
                CategorySelectionView(
                    selectedCategories: $viewModel.selectedCategories
                ) {
                    viewModel.goToNextStep()
                }
                .transition(.opacity)

            case .learningGoal:
                LearningGoalView(
                    dailyGoal: $viewModel.dailyGoal
                ) {
                    viewModel.goToNextStep()
                }
                .transition(.opacity)

            case .notificationPermission:
                NotificationPermissionView(
                    onContinue: {
                        viewModel.completeOnboarding()
                    },
                    onSkip: {
                        viewModel.completeOnboarding()
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
    }
}

// MARK: - Onboarding View Model

class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var selectedCategories: Set<Category> = []
    @Published var dailyGoal: Int = 10

    func goToNextStep() {
        withAnimation {
            switch currentStep {
            case .welcome:
                currentStep = .categorySelection
            case .categorySelection:
                currentStep = .learningGoal
            case .learningGoal:
                currentStep = .notificationPermission
            case .notificationPermission:
                break // Should not happen
            }
        }
    }

    func completeOnboarding() {
        // Save onboarding preferences
        saveOnboardingData()

        // Mark onboarding as completed
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        // Trigger app state change (handled by parent)
        NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
    }

    private func saveOnboardingData() {
        // Save selected categories
        let categoryStrings = selectedCategories.map { $0.rawValue }
        UserDefaults.standard.set(categoryStrings, forKey: "selectedCategories")

        // Save daily goal
        UserDefaults.standard.set(dailyGoal, forKey: "dailyGoal")
    }
}

// MARK: - Onboarding Step

enum OnboardingStep {
    case welcome
    case categorySelection
    case learningGoal
    case notificationPermission
}

// MARK: - Notification

extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
}

// MARK: - Previews
#if DEBUG
struct OnboardingCoordinatorPreviews: PreviewProvider {
    static var previews: some View {
        OnboardingCoordinator()
    }
}
#endif
