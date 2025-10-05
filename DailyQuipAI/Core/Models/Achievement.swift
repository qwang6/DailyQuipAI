//
//  Achievement.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import Foundation

/// User achievement/badge
struct Achievement: Identifiable, Codable, Equatable {
    let id: UUID
    let type: AchievementType
    let title: String
    let description: String
    let iconName: String // SF Symbol name
    let unlockedAt: Date?

    var isUnlocked: Bool {
        unlockedAt != nil
    }

    /// Create a locked achievement
    init(type: AchievementType) {
        self.id = UUID()
        self.type = type
        self.title = type.title
        self.description = type.description
        self.iconName = type.iconName
        self.unlockedAt = nil
    }

    /// Create an unlocked achievement
    init(type: AchievementType, unlockedAt: Date) {
        self.id = UUID()
        self.type = type
        self.title = type.title
        self.description = type.description
        self.iconName = type.iconName
        self.unlockedAt = unlockedAt
    }
}

/// Types of achievements users can unlock
enum AchievementType: String, Codable, CaseIterable {
    // Streak achievements
    case streak7 = "week_warrior"
    case streak30 = "monthly_master"
    case streak100 = "hundred_day_hero"
    case streak365 = "year_long_learner"

    // Cards learned achievements
    case cards50 = "half_century"
    case cards100 = "century_club"
    case cards365 = "daily_learner"
    case cards1000 = "knowledge_collector"

    // Category achievements
    case categoryExpert = "category_expert"
    case allCategories = "renaissance_mind"

    // Quiz achievements
    case perfectQuiz = "perfect_score"
    case quiz100 = "quiz_master"

    // Special achievements
    case earlyBird = "early_bird"
    case nightOwl = "night_owl"
    case weekendWarrior = "weekend_warrior"

    var title: String {
        switch self {
        case .streak7: return "Week Warrior"
        case .streak30: return "Monthly Master"
        case .streak100: return "Hundred Day Hero"
        case .streak365: return "Year-Long Learner"
        case .cards50: return "Half Century"
        case .cards100: return "Century Club"
        case .cards365: return "Daily Learner"
        case .cards1000: return "Knowledge Collector"
        case .categoryExpert: return "Category Expert"
        case .allCategories: return "Renaissance Mind"
        case .perfectQuiz: return "Perfect Score"
        case .quiz100: return "Quiz Master"
        case .earlyBird: return "Early Bird"
        case .nightOwl: return "Night Owl"
        case .weekendWarrior: return "Weekend Warrior"
        }
    }

    var description: String {
        switch self {
        case .streak7: return "Maintain a 7-day learning streak"
        case .streak30: return "Maintain a 30-day learning streak"
        case .streak100: return "Maintain a 100-day learning streak"
        case .streak365: return "Maintain a full year learning streak"
        case .cards50: return "Learn 50 knowledge cards"
        case .cards100: return "Learn 100 knowledge cards"
        case .cards365: return "Learn 365 knowledge cards"
        case .cards1000: return "Learn 1000 knowledge cards"
        case .categoryExpert: return "Master 50 cards in one category"
        case .allCategories: return "Learn cards from all 6 categories"
        case .perfectQuiz: return "Score 100% on a quiz"
        case .quiz100: return "Complete 100 quizzes"
        case .earlyBird: return "Complete daily cards before 9 AM"
        case .nightOwl: return "Complete daily cards after 10 PM"
        case .weekendWarrior: return "Learn every weekend for a month"
        }
    }

    var iconName: String {
        switch self {
        case .streak7, .streak30, .streak100, .streak365:
            return "flame.fill"
        case .cards50, .cards100, .cards365, .cards1000:
            return "book.fill"
        case .categoryExpert:
            return "star.fill"
        case .allCategories:
            return "crown.fill"
        case .perfectQuiz:
            return "checkmark.seal.fill"
        case .quiz100:
            return "brain.head.profile"
        case .earlyBird:
            return "sunrise.fill"
        case .nightOwl:
            return "moon.stars.fill"
        case .weekendWarrior:
            return "calendar.badge.checkmark"
        }
    }
}

// MARK: - Mock Data for Testing
#if DEBUG
extension Achievement {
    static func mock(type: AchievementType = .streak7, isUnlocked: Bool = true) -> Achievement {
        if isUnlocked {
            return Achievement(type: type, unlockedAt: Date())
        } else {
            return Achievement(type: type)
        }
    }

    static func mockArray(count: Int = 5) -> [Achievement] {
        let types = Array(AchievementType.allCases.prefix(count))
        return types.enumerated().map { index, type in
            Achievement.mock(type: type, isUnlocked: index < 3) // First 3 unlocked
        }
    }
}
#endif
