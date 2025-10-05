//
//  NetworkError.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import Foundation

/// Network-related errors
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case serverError(statusCode: Int, message: String?)
    case networkUnavailable
    case unauthorized
    case requestTimeout
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .serverError(let statusCode, let message):
            if let message = message {
                return "Server error (\(statusCode)): \(message)"
            }
            return "Server error: \(statusCode)"
        case .networkUnavailable:
            return "Network unavailable. Please check your connection."
        case .unauthorized:
            return "Unauthorized. Please sign in again."
        case .requestTimeout:
            return "Request timed out. Please try again."
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable:
            return "Check your internet connection and try again."
        case .unauthorized:
            return "Please sign in to continue."
        case .requestTimeout:
            return "The request took too long. Please try again."
        case .serverError:
            return "Please try again later."
        default:
            return nil
        }
    }
}
