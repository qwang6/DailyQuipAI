//
//  UserRepository.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import Foundation

/// Protocol for user data access
protocol UserRepository {
    /// Fetch the current user
    /// - Returns: The user if exists
    func fetchUser() async throws -> User?

    /// Save or update user data
    /// - Parameter user: The user to save
    func saveUser(_ user: User) async throws

    /// Update user settings
    /// - Parameter settings: The settings to update
    func updateSettings(_ settings: UserSettings) async throws

    /// Increment user's streak
    func incrementStreak() async throws

    /// Reset user's streak to 0
    func resetStreak() async throws

    /// Add a card to learned count
    func incrementCardsLearned() async throws

    /// Delete user (for testing or account deletion)
    func deleteUser() async throws
}

/// UserDefaults-based implementation of UserRepository
class UserDefaultsUserRepository: UserRepository {

    private let userKey = "gleam.currentUser"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func fetchUser() async throws -> User? {
        guard let data = defaults.data(forKey: userKey) else {
            return nil
        }

        let decoder = JSONDecoder()
        return try decoder.decode(User.self, from: data)
    }

    func saveUser(_ user: User) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(user)
        defaults.set(data, forKey: userKey)
    }

    func updateSettings(_ settings: UserSettings) async throws {
        guard var user = try await fetchUser() else {
            throw RepositoryError.userNotFound
        }

        user.settings = settings
        try await saveUser(user)
    }

    func incrementStreak() async throws {
        guard var user = try await fetchUser() else {
            throw RepositoryError.userNotFound
        }

        user.incrementStreak()
        try await saveUser(user)
    }

    func resetStreak() async throws {
        guard var user = try await fetchUser() else {
            throw RepositoryError.userNotFound
        }

        user.resetStreak()
        try await saveUser(user)
    }

    func incrementCardsLearned() async throws {
        guard var user = try await fetchUser() else {
            throw RepositoryError.userNotFound
        }

        user.addCardLearned()
        try await saveUser(user)
    }

    func deleteUser() async throws {
        defaults.removeObject(forKey: userKey)
    }
}

// MARK: - Repository Errors
enum RepositoryError: Error, LocalizedError {
    case userNotFound
    case dataCorrupted
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found. Please complete onboarding."
        case .dataCorrupted:
            return "Stored data is corrupted."
        case .saveFailed:
            return "Failed to save data."
        }
    }
}

// MARK: - Mock Repository for Testing
#if DEBUG
class MockUserRepository: UserRepository {
    var currentUser: User?
    var shouldThrowError = false

    func fetchUser() async throws -> User? {
        if shouldThrowError {
            throw RepositoryError.userNotFound
        }
        return currentUser
    }

    func saveUser(_ user: User) async throws {
        if shouldThrowError {
            throw RepositoryError.saveFailed
        }
        currentUser = user
    }

    func updateSettings(_ settings: UserSettings) async throws {
        if shouldThrowError {
            throw RepositoryError.saveFailed
        }
        guard var user = currentUser else {
            throw RepositoryError.userNotFound
        }
        user.settings = settings
        currentUser = user
    }

    func incrementStreak() async throws {
        if shouldThrowError {
            throw RepositoryError.saveFailed
        }
        guard var user = currentUser else {
            throw RepositoryError.userNotFound
        }
        user.incrementStreak()
        currentUser = user
    }

    func resetStreak() async throws {
        if shouldThrowError {
            throw RepositoryError.saveFailed
        }
        guard var user = currentUser else {
            throw RepositoryError.userNotFound
        }
        user.resetStreak()
        currentUser = user
    }

    func incrementCardsLearned() async throws {
        if shouldThrowError {
            throw RepositoryError.saveFailed
        }
        guard var user = currentUser else {
            throw RepositoryError.userNotFound
        }
        user.addCardLearned()
        currentUser = user
    }

    func deleteUser() async throws {
        if shouldThrowError {
            throw RepositoryError.saveFailed
        }
        currentUser = nil
    }
}
#endif
