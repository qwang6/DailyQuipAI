//
//  LLMCardGenerator.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import Foundation

/// LLM Provider types
enum LLMProvider {
    case gemini
    case openai
    case claude
}

/// Service to generate knowledge cards using LLM API
class LLMCardGenerator {

    private let apiKey: String
    private let provider: LLMProvider
    private let session: URLSession

    /// Initialize with API configuration
    /// - Parameters:
    ///   - apiKey: API key for LLM service
    ///   - provider: LLM provider to use
    init(apiKey: String, provider: LLMProvider = .gemini) {
        self.apiKey = apiKey
        self.provider = provider
        self.session = URLSession.shared
    }

    /// Generate daily knowledge cards based on user preferences
    /// - Parameters:
    ///   - categories: User's selected learning categories
    ///   - count: Number of cards to generate
    /// - Returns: Array of generated cards
    func generateDailyCards(categories: [Category], count: Int) async throws -> [Card] {
        let prompt = createBatchPrompt(categories: categories, count: count)
        let response = try await callLLM(prompt: prompt)
        return try parseBatchResponse(response, categories: categories)
    }

    /// Generate a single knowledge card for a specific category
    /// - Parameter category: The category for the card
    /// - Returns: Generated card
    private func generateCard(for category: Category) async throws -> Card {
        let prompt = createPromptForSingleCard(for: category)
        let response = try await callLLM(prompt: prompt)
        return try parseCardFromResponse(response, category: category)
    }

    /// Create a prompt for generating multiple knowledge cards in a single request
    private func createBatchPrompt(categories: [Category], count: Int) -> String {
        let categoryList = categories.map { $0.rawValue }.joined(separator: ", ")

        return """
        Generate exactly \(count) interesting and educational knowledge cards.

        Use a variety from these categories: \(categoryList)
        Distribute cards across different categories for diversity.

        Requirements for each card:
        - Title: A compelling, concise title (max 60 characters)
        - Content: An engaging explanation of a fascinating fact, concept, or story (150-300 words)
        - Make it accessible to general audiences
        - Include a surprising or thought-provoking element
        - Cite a credible source
        - Category: Must be one of the provided categories

        Respond with ONLY a JSON array of exactly \(count) objects:
        [
            {
                "title": "Card 1 title",
                "content": "Card 1 detailed content here",
                "source": "Source/reference",
                "tags": ["tag1", "tag2", "tag3"],
                "difficulty": 3,
                "category": "Science"
            },
            {
                "title": "Card 2 title",
                "content": "Card 2 detailed content here",
                "source": "Source/reference",
                "tags": ["tag1", "tag2", "tag3"],
                "difficulty": 2,
                "category": "History"
            }
        ]

        Difficulty scale: 1 (beginner) to 5 (advanced)

        IMPORTANT: Return exactly \(count) cards in a JSON array. Each card must include the "category" field.
        """
    }

    /// Create a prompt for generating a single knowledge card
    private func createPromptForSingleCard(for category: Category) -> String {
        return """
        Generate ONE interesting and educational knowledge card for the category: \(category.rawValue).

        Requirements:
        - Title: A compelling, concise title (max 60 characters)
        - Content: An engaging explanation of a fascinating fact, concept, or story (150-300 words)
        - Make it accessible to general audiences
        - Include a surprising or thought-provoking element
        - Cite a credible source

        Respond with ONLY a single JSON object (not an array):
        {
            "title": "Your title here",
            "content": "Your detailed content here",
            "source": "Source/reference",
            "tags": ["tag1", "tag2", "tag3"],
            "difficulty": 3
        }

        Difficulty scale: 1 (beginner) to 5 (advanced)

        IMPORTANT: Return only ONE JSON object, not an array of objects.
        """
    }

    /// Call the LLM API
    private func callLLM(prompt: String) async throws -> String {
        // Call actual API based on provider
        switch provider {
        case .gemini:
            return try await callGeminiAPI(prompt: prompt)
        case .openai:
            return try await callOpenAIAPI(prompt: prompt)
        case .claude:
            return try await callClaudeAPI(prompt: prompt)
        }
    }

    /// Call Google Gemini API
    private func callGeminiAPI(prompt: String) async throws -> String {
        let model = "gemini-2.5-flash"
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)"

        print("🚀 Calling Gemini API with model: \(model)")

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            throw LLMError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.8,
                "maxOutputTokens": 8000,  // Increased for batch generation
                "responseMimeType": "application/json"
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        print("📤 Request body prepared")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid HTTP response")
            throw LLMError.apiError("Invalid response from Gemini API")
        }

        print("📥 Received response with status: \(httpResponse.statusCode)")

        if !(200...299).contains(httpResponse.statusCode) {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ API Error: \(errorText)")
            throw LLMError.apiError("Gemini API error (\(httpResponse.statusCode)): \(errorText)")
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let candidates = json?["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            print("❌ Failed to parse response")
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Full response: \(responseString)")
            }
            throw LLMError.invalidResponse
        }

        print("✅ Successfully got text from Gemini")
        return text
    }

    /// Call OpenAI API
    private func callOpenAIAPI(prompt: String) async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": "You are an expert educator creating engaging knowledge cards."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.8,
            "max_tokens": 800,
            "response_format": ["type": "json_object"]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw LLMError.apiError("OpenAI API error")
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = json?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw LLMError.invalidResponse
        }

        return content
    }

    /// Call Claude API
    private func callClaudeAPI(prompt: String) async throws -> String {
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": "claude-3-sonnet-20240229",
            "max_tokens": 1000,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw LLMError.apiError("Claude API error")
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let content = json?["content"] as? [[String: Any]],
              let firstContent = content.first,
              let text = firstContent["text"] as? String else {
            throw LLMError.invalidResponse
        }

        return text
    }

    /// Parse batch LLM response into multiple Card objects
    private func parseBatchResponse(_ response: String, categories: [Category]) throws -> [Card] {
        print("📝 Raw LLM Batch Response length: \(response.count)")

        let cleanedResponse = response.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleanedResponse.data(using: .utf8) else {
            print("❌ Failed to convert to data")
            throw LLMError.invalidResponse
        }

        let decoder = JSONDecoder()

        do {
            let cardArray = try decoder.decode([LLMCardResponse].self, from: data)
            print("✅ Successfully decoded \(cardArray.count) cards from batch response")

            return cardArray.map { cardData in
                // Use category from LLM response if valid, otherwise pick from user's categories
                let category = Category(rawValue: cardData.category) ?? categories.randomElement() ?? .science
                return createCard(from: cardData, category: category)
            }
        } catch {
            print("❌ JSON Decode Error: \(error)")
            print("❌ Response length: \(cleanedResponse.count)")
            let preview = String(cleanedResponse.prefix(200))
            print("❌ Response preview: \(preview)")
            throw LLMError.invalidResponse
        }
    }

    /// Parse LLM response into a Card object
    private func parseCardFromResponse(_ response: String, category: Category) throws -> Card {
        print("📝 Raw LLM Response: \(response)")

        // Clean up the response - Gemini returns well-formatted JSON
        let cleanedResponse = response.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleanedResponse.data(using: .utf8) else {
            print("❌ Failed to convert to data")
            throw LLMError.invalidResponse
        }

        let decoder = JSONDecoder()

        // Try to decode as single object first
        do {
            let cardData = try decoder.decode(LLMCardResponse.self, from: data)
            print("✅ Successfully decoded card: \(cardData.title)")
            return createCard(from: cardData, category: category)
        } catch {
            print("⚠️ Failed to decode as single object, trying as array...")

            // If that fails, try to decode as array and take first element
            do {
                let cardArray = try decoder.decode([LLMCardResponse].self, from: data)
                guard let firstCard = cardArray.first else {
                    print("❌ Array is empty")
                    throw LLMError.invalidResponse
                }
                print("✅ Successfully decoded from array: \(firstCard.title)")
                return createCard(from: firstCard, category: category)
            } catch {
                print("❌ JSON Decode Error: \(error)")
                print("❌ Response length: \(cleanedResponse.count)")
                let preview = String(cleanedResponse.prefix(200))
                print("❌ Response preview: \(preview)")
                throw LLMError.invalidResponse
            }
        }
    }

    /// Create Card object from decoded data
    private func createCard(from cardData: LLMCardResponse, category: Category) -> Card {
        // Generate a placeholder image URL (in production, could use AI image generation)
        let imageURL = URL(string: "https://source.unsplash.com/800x600/?\(category.rawValue.lowercased())")!

        return Card(
            id: UUID(),
            title: cardData.title,
            category: category,
            frontImageURL: imageURL,
            backContent: cardData.content,
            tags: cardData.tags,
            source: cardData.source,
            difficulty: cardData.difficulty,
            estimatedReadTime: estimateReadTime(cardData.content),
            createdAt: Date()
        )
    }

    /// Estimate reading time based on content length
    private func estimateReadTime(_ content: String) -> Int {
        let wordCount = content.split(separator: " ").count
        let wordsPerMinute = 200
        let seconds = (wordCount * 60) / wordsPerMinute
        return max(seconds, 30) // Minimum 30 seconds
    }
}

// MARK: - Supporting Types

struct LLMCardResponse: Codable {
    let title: String
    let content: String
    let source: String
    let tags: [String]
    let difficulty: Int
    let category: String

    enum CodingKeys: String, CodingKey {
        case title
        case content
        case source
        case tags
        case difficulty
        case category
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        source = try container.decode(String.self, forKey: .source)
        tags = try container.decode([String].self, forKey: .tags)
        difficulty = try container.decode(Int.self, forKey: .difficulty)
        // Category is optional for backwards compatibility
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? "Science"
    }
}

enum LLMError: LocalizedError {
    case apiError(String)
    case invalidResponse
    case noAPIKey
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .apiError(let message):
            return "LLM API Error: \(message)"
        case .invalidResponse:
            return "Invalid response from LLM"
        case .noAPIKey:
            return "No API key configured"
        case .invalidURL:
            return "Invalid API URL"
        }
    }
}
