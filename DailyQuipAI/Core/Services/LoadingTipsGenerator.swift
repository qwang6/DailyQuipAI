//
//  LoadingTipsGenerator.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import Foundation
import SwiftUI
import Combine

/// Service to generate and manage loading tips
class LoadingTipsGenerator {

    private let llmGenerator: LLMCardGenerator

    init(llmGenerator: LLMCardGenerator) {
        // Create a fast LLM instance with gemini-2.5-flash-lite for tips
        let apiKey = Configuration.geminiAPIKey
        self.llmGenerator = LLMCardGenerator(
            apiKey: apiKey,
            provider: .gemini,
            modelName: "gemini-2.5-flash-lite"
        )
    }

    /// Get loading tips - always generates fresh tips from LLM (no cache, no fallback)
    func getLoadingTips() async throws -> [String] {
        print("🔄 Generating new loading tips from gemini-2.5-flash-lite...")
        let tips = try await generateTipsFromLLM()
        return tips
    }

    /// Generate loading tips from LLM - returns tips as individual strings
    private func generateTipsFromLLM() async throws -> [String] {
        // Generate 5 cards and extract interesting facts from them using gemini-2.5-flash-lite
        let cards = try await llmGenerator.generateDailyCards(
            categories: [.science, .history, .philosophy],
            count: 5
        )

        // Extract the title or first sentence from each card as a tip
        let tips = cards.map { card -> String in
            // Use the title as the tip, or extract first sentence from backContent
            if !card.title.isEmpty && card.title.count < 100 {
                return card.title
            } else if let firstSentence = card.backContent.components(separatedBy: ".").first,
                      firstSentence.count < 100 {
                return firstSentence + "."
            } else {
                // If content is too long, take first 80 chars
                let truncated = String(card.backContent.prefix(80))
                return truncated + "..."
            }
        }

        print("✅ Generated \(tips.count) tips from LLM cards")
        return tips
    }

}

/// Observable class for managing loading tips rotation
@MainActor
class LoadingTipsManager: ObservableObject {

    @Published var currentTip: String = "Loading your knowledge cards..."
    @Published var tips: [String] = []

    private var currentIndex: Int = 0
    private var rotationTimer: Timer?
    private let tipsGenerator: LoadingTipsGenerator
    private var isFetchingNextBatch = false

    init(tipsGenerator: LoadingTipsGenerator) {
        self.tipsGenerator = tipsGenerator
    }

    /// Start rotating tips every 4 seconds (non-blocking)
    func startRotatingTips() {
        // Immediately start fetching tips from LLM in the background (fire and forget)
        Task.detached(priority: .userInitiated) { [weak self] in
            await self?.fetchNextBatch()
        }

        // Also start the rotation timer immediately
        // Tips will appear as soon as fetchNextBatch completes
        rotationTimer?.invalidate()
        rotationTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.rotateTip()
            }
        }
    }

    /// Fetch next batch of 5 tips from LLM
    private func fetchNextBatch() async {
        guard !isFetchingNextBatch else { return }
        isFetchingNextBatch = true

        do {
            print("🔄 Fetching next batch of 5 tips from LLM...")
            let newTips = try await tipsGenerator.getLoadingTips()

            // Update on main actor to ensure UI updates
            await MainActor.run {
                let wasEmpty = self.tips.isEmpty
                self.tips.append(contentsOf: newTips)

                // If this is the first batch, show the first tip immediately
                if wasEmpty && !newTips.isEmpty {
                    self.currentTip = newTips[0]
                    self.currentIndex = 0
                    print("💡 Displaying first tip immediately: \(newTips[0])")
                }
                print("✅ Fetched \(newTips.count) tips, total now: \(self.tips.count)")
            }
        } catch {
            print("❌ Failed to fetch tips from LLM: \(error)")
            // No fallback - if LLM fails, we just stop adding new tips
            // The existing tips will keep rotating
        }

        isFetchingNextBatch = false
    }

    /// Stop rotating tips
    func stopRotatingTips() {
        rotationTimer?.invalidate()
        rotationTimer = nil
    }

    /// Rotate to next tip
    private func rotateTip() async {
        guard !tips.isEmpty else { return }

        currentIndex = (currentIndex + 1) % tips.count
        withAnimation(.easeInOut(duration: 0.3)) {
            currentTip = tips[currentIndex]
        }

        // When we've shown all tips in current batch, fetch next batch
        // Start fetching when we're on the last tip of current batch
        if currentIndex == tips.count - 1 && !isFetchingNextBatch {
            print("📝 Reached end of tips batch, fetching next batch...")
            await fetchNextBatch()
        }
    }

    deinit {
        rotationTimer?.invalidate()
    }
}
