//
//  DailyQuipAIApp.swift
//  DailyQuipAI
//
//  Created by Qian Wang on 10/4/25.
//

import SwiftUI

@main
struct DailyQuipAIApp: App {
    @StateObject private var languageManager = LanguageManager.shared

    var body: some Scene {
        WindowGroup {
            AppCoordinator()
                .environment(\.languageManager, languageManager)
                .environmentObject(languageManager)
        }
    }
}
