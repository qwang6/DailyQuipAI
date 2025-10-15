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
    private let modelName: String

    /// Initialize with API configuration
    /// - Parameters:
    ///   - apiKey: API key for LLM service
    ///   - provider: LLM provider to use
    ///   - modelName: Model name to use (defaults to gemini-2.5-flash)
    init(apiKey: String, provider: LLMProvider = .gemini, modelName: String = "gemini-2.5-flash") {
        self.apiKey = apiKey
        self.provider = provider
        self.modelName = modelName
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
        let currentLanguage = LanguageManager.shared.currentLanguage

        // Use Chinese prompt if language is Chinese
        if currentLanguage == .chinese {
            return createChineseBatchPrompt(categories: categories, count: count, categoryList: categoryList)
        }

        return """
        Generate exactly \(count) interesting and educational knowledge cards.

        Use a variety from these categories: \(categoryList)
        Distribute cards across different categories for diversity.

        Requirements for each card:
        - Title: A compelling, concise title (max 60 characters)
        - Content: A comprehensive and deeply engaging explanation (MINIMUM 1000 words, preferably 1200-1500 words)
        - **FORMAT: Use Markdown formatting for rich text**
          - Use **bold** for emphasis and key terms
          - Use *italic* for subtle emphasis or foreign terms
          - Use `code` for technical terms or short quotes
          - Use ## for section headers, ### for subsection headers
          - Use proper paragraphs with blank lines between them
        - Structure the content with clear sections (Introduction, Background, Examples, Implications, etc.)
        - Provide extensive context, historical background, and current relevance
        - Include multiple detailed examples, case studies, or real-world applications
        - Explain the broader implications and significance
        - Add interesting anecdotes, surprising facts, or lesser-known details
        - Make it accessible to general audiences while being thorough and in-depth
        - Include thought-provoking questions or connections to other topics
        - Cite credible sources and reference relevant research
        - Category: Must be one of the provided categories

        IMPORTANT:
        1. The content MUST be at least 1000 words. Shorter content will be rejected.
        2. The content MUST use Markdown formatting (bold, italic, headers, etc.).

        Respond with ONLY a valid JSON array of exactly \(count) objects.

        REQUIRED fields for each card:
        - "title": string (max 60 chars)
        - "content": string (1000+ words with Markdown)
        - "category": string (one of: \(categoryList))

        OPTIONAL fields (can be omitted):
        - "source": string (reference/citation)
        - "tags": array of strings
        - "difficulty": number 1-5

        Example format:
        [
            {
                "title": "Card 1 title",
                "content": "Card 1 detailed content here with **Markdown**...",
                "category": "Science"
            },
            {
                "title": "Card 2 title",
                "content": "Card 2 detailed content here...",
                "category": "History"
            }
        ]

        CRITICAL JSON RULES:
        - Return ONLY the JSON array, no markdown code blocks
        - Use ONLY standard double quotes (") for JSON strings
        - NEVER use curly quotes (" " ' ') - they break JSON parsing
        - NEVER use smart quotes or typographic quotes
        - In JSON strings, backslash (\\) is ONLY valid before: " \\ / b f n r t u
        - ANY other character after backslash is INVALID (like \\s \\p \\a \\x etc)
        - If you need a literal backslash in content, use \\\\
        - Do NOT put actual newlines/line breaks inside string values - use \\n instead
        - Do NOT escape Markdown characters: * # - _ are valid without backslash
        - Do NOT use em dashes (—) or en dashes (–) - use regular hyphen (-)
        - Return exactly \(count) cards in a JSON array
        - MUST include: title, content, category
        - MAY omit: source, tags, difficulty

        VALIDATION STEP (MANDATORY):
        Before returning your response, verify:
        1. The response starts with [ and ends with ]
        2. All quotes are standard ASCII double quotes (")
        3. No curly quotes (" " ' ') anywhere in the response
        4. All string values are properly escaped
        5. No actual newline characters inside string values (use \\n)
        5. The JSON is valid and can be parsed
        """
    }

    /// Create Chinese batch prompt
    private func createChineseBatchPrompt(categories: [Category], count: Int, categoryList: String) -> String {
        return """
        生成恰好 \(count) 张有趣且具有教育意义的知识卡片。

        从以下类别中选择多样化的内容：\(categoryList)
        将卡片分布在不同的类别中以确保多样性。

        每张卡片的要求：
        - 标题：引人注目、简洁的标题（最多60个字符）
        - 内容：全面而深入的解释（最少1000字，最好1200-1500字）
        - **格式：使用 Markdown 格式化富文本**
          - 使用 **粗体** 强调关键术语和重点
          - 使用 *斜体* 表示微妙强调或外来术语
          - 使用 `代码` 表示技术术语或短引语
          - 使用 ## 表示章节标题，### 表示小节标题
          - 段落之间用空行分隔
        - 用清晰的章节组织内容（引言、背景、实例、影响等）
        - 提供广泛的背景、历史渊源和当代意义
        - 包含多个详细的例子、案例研究或实际应用
        - 解释更广泛的影响和重要性
        - 添加有趣的轶事、令人惊讶的事实或鲜为人知的细节
        - 内容应通俗易懂，同时保持深入和全面
        - 包含引人深思的问题或与其他主题的联系
        - 引用可信的来源并参考相关研究
        - 类别：必须是提供的类别之一

        重要：
        1. 内容必须至少1000字。字数不足的内容将被拒绝。
        2. 内容必须使用 Markdown 格式（粗体、斜体、标题等）。

        仅用有效的 JSON 数组响应，包含恰好 \(count) 个对象。

        每张卡片的必需字段：
        - "title": 字符串（最多60字符）
        - "content": 字符串（1000+字，带 Markdown 格式）
        - "category": 字符串（从以下选择：\(categoryList)）

        可选字段（可以省略）：
        - "source": 字符串（来源/参考）
        - "tags": 字符串数组
        - "difficulty": 数字 1-5

        示例格式：
        [
            {
                "title": "卡片1标题",
                "content": "卡片1的详细内容，带有 **Markdown** 格式...",
                "category": "Science"
            },
            {
                "title": "卡片2标题",
                "content": "卡片2的详细内容...",
                "category": "History"
            }
        ]

        关键 JSON 规则：
        - 仅返回 JSON 数组，不要有 markdown 代码块
        - 只使用标准的 ASCII 双引号 (")
        - 绝不使用中文引号（" " ' '）或弯引号 - 它们会破坏 JSON 解析
        - 绝不使用智能引号或排版引号
        - 在 JSON 字符串中，反斜杠 (\\) 只能出现在这些字符之前：" \\ / b f n r t u
        - 反斜杠后面的任何其他字符都是无效的（比如 \\s \\p \\a \\x 等）
        - 如果内容中需要字面的反斜杠，使用 \\\\
        - 不要在字符串值中放入真实的换行符 - 使用 \\n 代替
        - 不要转义 Markdown 字符：* # - _ 可以直接使用，不需要反斜杠
        - 不要使用全角破折号（—）或连接号（–）- 使用普通连字符 (-)
        - 返回恰好 \(count) 张卡片的 JSON 数组
        - 必须包含：title, content, category
        - 可以省略：source, tags, difficulty

        验证步骤（必须执行）：
        在返回响应之前，请验证：
        1. 响应以 [ 开头，以 ] 结尾
        2. 所有引号都是标准的 ASCII 双引号 (")
        3. 响应中任何地方都没有中文引号（" " ' '）
        4. 所有字符串值都正确转义
        5. 字符串值中没有真实的换行符（使用 \\n）
        6. JSON 是有效的，可以被解析
        """
    }

    /// Create a prompt for generating a single knowledge card
    private func createPromptForSingleCard(for category: Category) -> String {
        return """
        Generate ONE interesting and educational knowledge card for the category: \(category.rawValue).

        Requirements:
        - Title: A compelling, concise title (max 60 characters)
        - Content: A comprehensive and deeply engaging explanation (MINIMUM 1000 words, preferably 1200-1500 words)
        - **FORMAT: Use Markdown formatting for rich text**
          - Use **bold** for emphasis and key terms
          - Use *italic* for subtle emphasis or foreign terms
          - Use `code` for technical terms or short quotes
          - Use ## for section headers, ### for subsection headers
          - Use proper paragraphs with blank lines between them
        - Structure the content with clear sections (Introduction, Background, Examples, Implications, etc.)
        - Provide extensive context, historical background, and current relevance
        - Include multiple detailed examples, case studies, or real-world applications
        - Explain the broader implications and significance
        - Add interesting anecdotes, surprising facts, or lesser-known details
        - Make it accessible to general audiences while being thorough and in-depth
        - Include thought-provoking questions or connections to other topics
        - Cite credible sources and reference relevant research

        IMPORTANT:
        1. The content MUST be at least 1000 words. Shorter content will be rejected.
        2. The content MUST use Markdown formatting (bold, italic, headers, etc.).

        Respond with ONLY a single valid JSON object (not an array):
        {
            "title": "Your title here",
            "content": "Your detailed content here",
            "source": "Source/reference",
            "tags": ["tag1", "tag2", "tag3"],
            "difficulty": 3
        }

        Difficulty scale: 1 (beginner) to 5 (advanced)

        CRITICAL JSON RULES:
        - Return ONLY the JSON object, no markdown code blocks
        - Use double quotes for all strings
        - Do NOT use single quotes or apostrophes inside strings - use the letter directly
        - Properly escape any special characters
        - Return only ONE JSON object, not an array of objects
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
        let model = self.modelName
        // SECURITY: API key in header instead of URL to prevent exposure in error logs
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent"

        print("🚀 Calling Gemini API with model: \(model)")

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            throw LLMError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")  // API key in header for security

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
                "maxOutputTokens": 16000,  // Increased for longer, detailed content
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
            "max_tokens": 4000,  // Increased for longer, detailed content
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
            "max_tokens": 4000,  // Increased for longer, detailed content
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

    /// Fix unescaped newlines and invalid escape sequences inside JSON string values
    private func fixUnescapedNewlinesInJSON(_ json: String) -> String {
        var result = ""
        var inString = false
        var i = json.startIndex

        while i < json.endIndex {
            let char = json[i]

            // Track if we're inside a string value
            if char == "\"" {
                // Check if this quote is escaped
                var backslashCount = 0
                var checkIndex = i
                while checkIndex > json.startIndex {
                    checkIndex = json.index(before: checkIndex)
                    if json[checkIndex] == "\\" {
                        backslashCount += 1
                    } else {
                        break
                    }
                }
                // If odd number of backslashes, the quote is escaped
                if backslashCount % 2 == 0 {
                    inString.toggle()
                }
                result.append(char)
                i = json.index(after: i)
            } else if inString && char == "\\" {
                // Found a backslash inside a string - check what follows
                let nextIndex = json.index(after: i)
                if nextIndex < json.endIndex {
                    let nextChar = json[nextIndex]
                    // Valid JSON escape sequences: " \ / b f n r t u
                    if nextChar == "\"" || nextChar == "\\" || nextChar == "/" ||
                       nextChar == "b" || nextChar == "f" || nextChar == "n" ||
                       nextChar == "r" || nextChar == "t" || nextChar == "u" {
                        // Valid escape - keep both characters
                        result.append(char)
                        result.append(nextChar)
                        i = json.index(after: nextIndex)
                    } else {
                        // Invalid escape - escape the backslash itself
                        result.append("\\\\")
                        i = json.index(after: i)
                    }
                } else {
                    result.append(char)
                    i = json.index(after: i)
                }
            } else if inString {
                // Inside a string - escape unescaped control characters
                switch char {
                case "\n":
                    result.append("\\n")
                case "\r":
                    result.append("\\r")
                case "\t":
                    result.append("\\t")
                default:
                    result.append(char)
                }
                i = json.index(after: i)
            } else {
                // Outside string - keep as is
                result.append(char)
                i = json.index(after: i)
            }
        }

        return result
    }

    /// Clean JSON response to fix common LLM formatting issues
    private func cleanJSONResponse(_ response: String) -> String {
        var cleaned = response.trimmingCharacters(in: .whitespacesAndNewlines)

        // Fix common issues with Gemini's JSON output
        // 1. Remove markdown code blocks if present
        if cleaned.hasPrefix("```json") {
            cleaned = cleaned.replacingOccurrences(of: "```json", with: "")
            cleaned = cleaned.replacingOccurrences(of: "```", with: "")
            cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        // 2. Extract only the JSON array part (between first [ and last matching ])
        // This handles cases where LLM adds extra text after the JSON
        if let firstBracket = cleaned.firstIndex(of: "[") {
            // Find the matching closing bracket
            var depth = 0
            var lastMatchingBracket: String.Index?

            for (index, char) in cleaned[firstBracket...].enumerated() {
                let currentIndex = cleaned.index(firstBracket, offsetBy: index)
                if char == "[" {
                    depth += 1
                } else if char == "]" {
                    depth -= 1
                    if depth == 0 {
                        lastMatchingBracket = currentIndex
                        break
                    }
                }
            }

            if let endBracket = lastMatchingBracket {
                cleaned = String(cleaned[firstBracket...endBracket])
            }
        }

        // 3. Fix unescaped newlines and control characters in JSON strings
        // This is a more robust approach: find all string values and fix them
        cleaned = fixUnescapedNewlinesInJSON(cleaned)

        // 4. Fix invalid escape sequences
        // \' is not valid in JSON - should just be '
        cleaned = cleaned.replacingOccurrences(of: "\\'", with: "'")
        // \* is not valid in JSON - should just be *
        cleaned = cleaned.replacingOccurrences(of: "\\*", with: "*")
        // \# is not valid in JSON - should just be #
        cleaned = cleaned.replacingOccurrences(of: "\\#", with: "#")
        // \- is not valid in JSON - should just be -
        cleaned = cleaned.replacingOccurrences(of: "\\-", with: "-")
        // \_ is not valid in JSON - should just be _
        cleaned = cleaned.replacingOccurrences(of: "\\_", with: "_")

        // 5. Replace Chinese/curly quotes with escaped quotes to avoid JSON parsing issues
        // Use Unicode escapes to avoid literal quote characters in code
        let leftDoubleQuote = "\u{201C}"  // "
        let rightDoubleQuote = "\u{201D}" // "
        let leftSingleQuote = "\u{2018}"  // '
        let rightSingleQuote = "\u{2019}" // '
        let emDash = "\u{2014}"           // —
        let enDash = "\u{2013}"           // –

        cleaned = cleaned.replacingOccurrences(of: leftDoubleQuote, with: "\\\"")
        cleaned = cleaned.replacingOccurrences(of: rightDoubleQuote, with: "\\\"")
        cleaned = cleaned.replacingOccurrences(of: leftSingleQuote, with: "'")
        cleaned = cleaned.replacingOccurrences(of: rightSingleQuote, with: "'")

        // 6. Fix other problematic characters that might break JSON
        cleaned = cleaned.replacingOccurrences(of: emDash, with: "-")
        cleaned = cleaned.replacingOccurrences(of: enDash, with: "-")

        return cleaned
    }

    /// Parse batch LLM response into multiple Card objects
    private func parseBatchResponse(_ response: String, categories: [Category]) throws -> [Card] {
        print("📝 Raw LLM Batch Response length: \(response.count)")

        let cleanedResponse = cleanJSONResponse(response)

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

            // Show context around the error location if possible
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .dataCorrupted(let context):
                    print("❌ Data corrupted: \(context.debugDescription)")
                    if let underlyingError = context.underlyingError as NSError? {
                        print("❌ Underlying error: \(underlyingError.localizedDescription)")
                        // Try to extract the error position
                        if let errorIndex = underlyingError.userInfo["NSJSONSerializationErrorIndex"] as? Int,
                           errorIndex < cleanedResponse.count {
                            let start = max(0, errorIndex - 100)
                            let end = min(cleanedResponse.count, errorIndex + 100)
                            // Safe substring extraction
                            let startIndex = cleanedResponse.index(cleanedResponse.startIndex, offsetBy: start)
                            let endIndex = cleanedResponse.index(cleanedResponse.startIndex, offsetBy: end)
                            if startIndex < cleanedResponse.endIndex && endIndex <= cleanedResponse.endIndex {
                                let errorContext = String(cleanedResponse[startIndex..<endIndex])
                                print("❌ Error context (±100 chars): \(errorContext)")
                            }
                        }
                    }
                default:
                    break
                }
            }

            let preview = String(cleanedResponse.prefix(500))
            print("❌ Response preview (first 500 chars): \(preview)")

            // Save the problematic response for debugging
            if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let debugPath = documentsPath.appendingPathComponent("debug_json_error.txt")
                try? cleanedResponse.write(to: debugPath, atomically: true, encoding: .utf8)
                print("💾 Saved problematic JSON to: \(debugPath.path)")
            }

            throw LLMError.invalidResponse
        }
    }

    /// Parse LLM response into a Card object
    private func parseCardFromResponse(_ response: String, category: Category) throws -> Card {
        print("📝 Raw LLM Response: \(response)")

        // Clean up the response
        let cleanedResponse = cleanJSONResponse(response)

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
            tags: cardData.tags ?? [],  // Default to empty array if missing
            source: cardData.source ?? "AI Generated",  // Default source if missing
            difficulty: cardData.difficulty ?? 3,  // Default to medium difficulty if missing
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
    let source: String?        // Optional - provide default if missing
    let tags: [String]?        // Optional - provide default if missing
    let difficulty: Int?       // Optional - provide default if missing
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

        // Make these fields optional with sensible defaults
        source = try container.decodeIfPresent(String.self, forKey: .source)
        tags = try container.decodeIfPresent([String].self, forKey: .tags)
        difficulty = try container.decodeIfPresent(Int.self, forKey: .difficulty)

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
