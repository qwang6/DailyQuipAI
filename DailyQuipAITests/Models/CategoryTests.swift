//
//  CategoryTests.swift
//  DailyQuipAITests
//
//  Created by Claude on 10/4/25.
//

import XCTest
@testable import DailyQuipAI

final class CategoryTests: XCTestCase {

    func testCategoryCount() {
        // Verify we have exactly 6 categories as per PRD
        XCTAssertEqual(Category.allCases.count, 6)
    }

    func testCategoryRawValues() {
        // Test each category has correct raw value
        XCTAssertEqual(Category.history.rawValue, "History")
        XCTAssertEqual(Category.science.rawValue, "Science")
        XCTAssertEqual(Category.art.rawValue, "Art")
        XCTAssertEqual(Category.life.rawValue, "Life")
        XCTAssertEqual(Category.finance.rawValue, "Finance")
        XCTAssertEqual(Category.philosophy.rawValue, "Philosophy")
    }

    func testCategoryIcons() {
        // Verify each category has an icon
        for category in Category.allCases {
            XCTAssertFalse(category.icon.isEmpty, "\(category.rawValue) should have an icon")
        }
    }

    func testCategoryDescriptions() {
        // Verify each category has a description
        for category in Category.allCases {
            XCTAssertFalse(category.description.isEmpty, "\(category.rawValue) should have a description")
        }
    }

    func testCategoryIdentifiable() {
        // Test that Category conforms to Identifiable
        let category = Category.history
        XCTAssertEqual(category.id, category.rawValue)
    }

    func testCategoryCodable() throws {
        // Test encoding
        let category = Category.science
        let encoder = JSONEncoder()
        let data = try encoder.encode(category)
        XCTAssertFalse(data.isEmpty)

        // Test decoding
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Category.self, from: data)
        XCTAssertEqual(decoded, category)
    }

    func testCategoryArrayCodable() throws {
        // Test encoding an array of categories
        let categories: [DailyQuipAI.Category] = [.history, .science, .art]
        let encoder = JSONEncoder()
        let data = try encoder.encode(categories)

        // Test decoding
        let decoder = JSONDecoder()
        let decoded = try decoder.decode([DailyQuipAI.Category].self, from: data)
        XCTAssertEqual(decoded, categories)
    }
}
