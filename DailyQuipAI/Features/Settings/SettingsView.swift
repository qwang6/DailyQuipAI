//
//  SettingsView.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import SwiftUI
import Combine

/// Settings view for app configuration
struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showPaywall = false

    var body: some View {
        NavigationView {
            List {
                // Subscription Section
                Section {
                    HStack {
                        Image(systemName: subscriptionManager.isPremium ? "crown.fill" : "star.fill")
                            .foregroundStyle(LinearGradient.brand)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text(subscriptionManager.isPremium ? "Premium" : "Free")
                                .font(.bodyMedium)
                                .foregroundColor(.textPrimary)

                            if let remaining = subscriptionManager.remainingCardsToday {
                                Text("\(remaining) cards remaining today")
                                    .font(.captionLarge)
                                    .foregroundColor(.textSecondary)
                            } else {
                                Text("Unlimited cards")
                                    .font(.captionLarge)
                                    .foregroundColor(.textSecondary)
                            }
                        }

                        Spacer()

                        if !subscriptionManager.isPremium {
                            Button("Upgrade") {
                                showPaywall = true
                            }
                            .font(.labelMedium)
                            .foregroundColor(.brandPrimary)
                        }
                    }
                } header: {
                    Text("Subscription")
                }

                // Category Preferences Section
                Section {
                    NavigationLink(destination: CategoryPreferencesView(
                        selectedCategories: $viewModel.selectedCategories
                    )) {
                        HStack {
                            Image(systemName: "books.vertical.fill")
                                .foregroundStyle(LinearGradient.brand)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: Spacing.xxs) {
                                Text("Preferred Categories")
                                    .font(.bodyMedium)
                                    .foregroundColor(.textPrimary)

                                Text("\(viewModel.selectedCategories.count) selected")
                                    .font(.captionLarge)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                } header: {
                    Text("Content")
                }

                // Learning Goals Section
                Section {
                    HStack {
                        Image(systemName: "target")
                            .foregroundStyle(LinearGradient.brand)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text("Daily Goal")
                                .font(.bodyMedium)
                                .foregroundColor(.textPrimary)

                            Text("\(viewModel.dailyGoal) cards per day")
                                .font(.captionLarge)
                                .foregroundColor(.textSecondary)
                        }

                        Spacer()

                        Stepper("", value: $viewModel.dailyGoal, in: 3...20)
                            .labelsHidden()
                    }
                } header: {
                    Text("Learning")
                }

                // Notifications Section
                Section {
                    Toggle(isOn: $viewModel.notificationsEnabled) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(LinearGradient.brand)
                                .frame(width: 28)

                            Text("Daily Reminders")
                                .font(.bodyMedium)
                                .foregroundColor(.textPrimary)
                        }
                    }

                    if viewModel.notificationsEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: $viewModel.reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .font(.bodyMedium)
                    }
                } header: {
                    Text("Notifications")
                }

                // Appearance Section
                Section {
                    Picker("Theme", selection: $viewModel.theme) {
                        ForEach(Theme.allCases, id: \.self) { theme in
                            Text(theme.displayName)
                                .tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Appearance")
                }

                // About Section
                Section {
                    HStack {
                        Text("Version")
                            .font(.bodyMedium)
                        Spacer()
                        Text("1.0.0")
                            .font(.bodyMedium)
                            .foregroundColor(.textSecondary)
                    }

                    Link(destination: URL(string: "https://gleam.app/privacy")!) {
                        Text("Privacy Policy")
                            .font(.bodyMedium)
                    }

                    Link(destination: URL(string: "https://gleam.app/terms")!) {
                        Text("Terms of Service")
                            .font(.bodyMedium)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView(
                    onUpgrade: { subscriptionType in
                        // Handle subscription upgrade
                        subscriptionManager.updateSubscription(to: subscriptionType)
                        showPaywall = false
                    },
                    onDismiss: {
                        showPaywall = false
                    }
                )
            }
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Category Preferences View

struct CategoryPreferencesView: View {
    @Binding var selectedCategories: Set<Category>

    private var columns: [GridItem] {
        let columnCount = DeviceSize.isIPad ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: Spacing.md), count: columnCount)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                Text("Select the topics you'd like to learn about. You need at least one category selected.")
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
                    .paddingVertical()

                LazyVGrid(columns: columns, spacing: Spacing.md) {
                    ForEach(Category.allCases) { category in
                        CategorySelectionCard(
                            category: category,
                            isSelected: selectedCategories.contains(category)
                        ) {
                            toggleCategory(category)
                        }
                    }
                }
                .padding(.horizontal, Spacing.xl)
            }
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggleCategory(_ category: Category) {
        if selectedCategories.contains(category) {
            // Don't allow removing the last category
            if selectedCategories.count > 1 {
                selectedCategories.remove(category)
                HapticFeedback.light()
            } else {
                HapticFeedback.error()
            }
        } else {
            selectedCategories.insert(category)
            HapticFeedback.light()
        }
    }
}

// MARK: - Settings View Model

class SettingsViewModel: ObservableObject {
    @Published var selectedCategories: Set<Category> {
        didSet {
            saveCategories()
        }
    }

    @Published var dailyGoal: Int {
        didSet {
            UserDefaults.standard.set(dailyGoal, forKey: "dailyGoal")
        }
    }

    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }

    @Published var reminderTime: Date {
        didSet {
            UserDefaults.standard.set(reminderTime, forKey: "reminderTime")
        }
    }

    @Published var theme: Theme {
        didSet {
            UserDefaults.standard.set(theme.rawValue, forKey: "theme")
            ThemeManager.shared.currentTheme = theme
        }
    }

    init() {
        // Load selected categories
        if let categoryStrings = UserDefaults.standard.stringArray(forKey: "selectedCategories"),
           !categoryStrings.isEmpty {
            self.selectedCategories = Set(categoryStrings.compactMap { Category(rawValue: $0) })
        } else {
            self.selectedCategories = Set(Category.allCases)
        }

        // Load daily goal
        let savedGoal = UserDefaults.standard.integer(forKey: "dailyGoal")
        self.dailyGoal = savedGoal > 0 ? savedGoal : 5

        // Load notification settings
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")

        // Load reminder time
        if let savedTime = UserDefaults.standard.object(forKey: "reminderTime") as? Date {
            self.reminderTime = savedTime
        } else {
            // Default to 9:00 AM
            var components = DateComponents()
            components.hour = 9
            components.minute = 0
            self.reminderTime = Calendar.current.date(from: components) ?? Date()
        }

        // Load theme
        if let themeString = UserDefaults.standard.string(forKey: "theme"),
           let savedTheme = Theme(rawValue: themeString) {
            self.theme = savedTheme
        } else {
            self.theme = .system
        }
    }

    private func saveCategories() {
        let categoryStrings = selectedCategories.map { $0.rawValue }
        UserDefaults.standard.set(categoryStrings, forKey: "selectedCategories")
    }
}


// MARK: - Previews
#if DEBUG
struct SettingsViewPreviews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
