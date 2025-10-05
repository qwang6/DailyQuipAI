//
//  AppCoordinator.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import SwiftUI
import Combine

/// Main app coordinator handling navigation between onboarding and main app
struct AppCoordinator: View {
    @StateObject private var viewModel = AppCoordinatorViewModel()

    var body: some View {
        Group {
            if viewModel.hasCompletedOnboarding {
                DailyCardsView()
            } else {
                OnboardingCoordinator()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
            viewModel.hasCompletedOnboarding = true
        }
    }
}

// MARK: - App Coordinator View Model

class AppCoordinatorViewModel: ObservableObject {
    @Published var hasCompletedOnboarding: Bool

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
}

// MARK: - Previews
#if DEBUG
struct AppCoordinatorPreviews: PreviewProvider {
    static var previews: some View {
        AppCoordinator()
    }
}
#endif
