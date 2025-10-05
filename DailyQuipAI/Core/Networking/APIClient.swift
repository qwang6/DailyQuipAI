//
//  APIClient.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import Foundation

/// Protocol for API client
protocol APIClient {
    /// Make a network request
    /// - Parameter endpoint: The API endpoint to call
    /// - Returns: Decoded response of type T
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

/// URLSession-based API client implementation
class URLSessionAPIClient: APIClient {

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    /// Initialize with base URL
    /// - Parameters:
    ///   - baseURL: The base URL for the API
    ///   - session: URLSession to use (defaults to .shared)
    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()

        // Configure date decoding strategy
        self.decoder.dateDecodingStrategy = .iso8601
        self.encoder.dateEncodingStrategy = .iso8601
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        // Build URL
        guard var urlComponents = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL
        }

        // Add query parameters
        if let queryItems = endpoint.queryItems {
            urlComponents.queryItems = queryItems
        }

        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }

        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = 30

        // Add headers
        for (key, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Add body if present
        if let body = endpoint.body {
            do {
                request.httpBody = try encoder.encode(AnyEncodable(body))
            } catch {
                throw NetworkError.encodingError(error)
            }
        }

        // Make request
        do {
            let (data, response) = try await session.data(for: request)

            // Check HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(NSError(domain: "InvalidResponse", code: -1))
            }

            // Handle status codes
            switch httpResponse.statusCode {
            case 200...299:
                // Success - decode and return
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw NetworkError.decodingError(error)
                }

            case 401:
                throw NetworkError.unauthorized

            case 408:
                throw NetworkError.requestTimeout

            case 400...499:
                let message = try? decoder.decode(ErrorResponse.self, from: data)
                throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: message?.message)

            case 500...599:
                let message = try? decoder.decode(ErrorResponse.self, from: data)
                throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: message?.message)

            default:
                throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: nil)
            }

        } catch let error as NetworkError {
            throw error
        } catch {
            // Check for network unavailable
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorNotConnectedToInternet {
                throw NetworkError.networkUnavailable
            }
            throw NetworkError.unknown(error)
        }
    }
}

// MARK: - Helper Types

/// Wrapper to encode any Encodable type
private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init<T: Encodable>(_ wrapped: T) {
        _encode = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

/// Standard error response from server
private struct ErrorResponse: Decodable {
    let message: String
}

// MARK: - Mock API Client for Testing
#if DEBUG
class MockAPIClient: APIClient {
    var mockData: Data?
    var mockError: Error?
    var shouldFail: Bool = false
    var delay: TimeInterval = 0

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        // Simulate network delay
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }

        // Return error if should fail
        if shouldFail {
            throw mockError ?? NetworkError.serverError(statusCode: 500, message: "Mock error")
        }

        // Return mock data if provided
        if let mockData = mockData {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                return try decoder.decode(T.self, from: mockData)
            } catch {
                throw NetworkError.decodingError(error)
            }
        }

        // Return empty/default data based on type
        // This is a simplified version - in real testing, you'd provide proper mock data
        throw NetworkError.noData
    }

    /// Helper to set mock response
    func setMockResponse<T: Encodable>(_ object: T) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        mockData = try encoder.encode(object)
    }
}
#endif
