# Batch Generation & Prefetching Optimization

## Overview

This optimization reduces LLM API calls by implementing **batch generation** and **intelligent prefetching** for knowledge cards.

## Key Improvements

### 1. Batch Generation (Single API Call)

**Before**: Sequential API calls for each card
```swift
// ❌ OLD: 5 cards = 5 API calls
for _ in 0..<5 {
    let card = try await generateCard(for: category)
    cards.append(card)
}
```

**After**: Single API call for all cards
```swift
// ✅ NEW: 5 cards = 1 API call
let cards = try await llmGenerator.generateDailyCards(
    categories: selectedCategories,
    count: 5  // All cards in one batch
)
```

**Benefits**:
- **5x fewer API calls** (5 cards = 1 call instead of 5)
- **Faster loading** (one network round-trip instead of multiple)
- **Lower latency** (no sequential waiting)

### 2. Intelligent Prefetching

**Strategy**: Fetch next batch when user is on second-to-last card

```
User viewing cards:  [1] [2] [3] [4] [5]
                                    ↑
                              Prefetch triggered here
```

**Implementation**:
```swift
// When user is on card 4 of 5
if cardsRemaining == 1 && !isPrefetching {
    Task {
        await prefetchNextBatch()  // Fetch in background
    }
}
```

**Benefits**:
- **Zero waiting time** between batches
- **Seamless user experience** (cards always ready)
- **Background fetching** (doesn't block UI)

### 3. Two-Batch Cache System

**Architecture**: Maintain two batches in memory/cache

```
┌──────────────┐         ┌──────────────┐
│ Current Batch│ ──────→ │  Next Batch  │
│  (5 cards)   │         │  (5 cards)   │
│              │         │ (prefetched) │
└──────────────┘         └──────────────┘
      ↓                         ↓
  UserDefaults             UserDefaults
  "cachedDailyCards"    "nextBatchDailyCards"
```

**Flow**:
1. User views current batch
2. When on card 4/5, start prefetching next batch
3. When card 5/5 is viewed, instantly load next batch
4. Immediately start prefetching the batch after that

### 4. Persistent Cache Across Sessions

**Benefits**:
- Cards survive app restarts
- Cache expires daily (new content each day)
- Tracks viewing progress per session

**Cache Keys**:
```swift
"cachedDailyCards"     // Current batch
"nextBatchDailyCards"  // Prefetched next batch
"lastCardFetchDate"    // Cache expiration tracking
"currentCardIndex"     // User progress tracking
```

## API Configuration

### Gemini 2.0 Flash Settings

```swift
"generationConfig": [
    "temperature": 0.8,
    "maxOutputTokens": 8000,  // Supports ~10-15 cards per batch
    "responseMimeType": "application/json"
]
```

**Token Budget**:
- Each card: ~500-700 tokens
- Batch of 5 cards: ~3000-3500 tokens
- Max capacity: 8000 tokens ≈ 10-12 cards

## Prompt Engineering

### Batch Prompt Structure

```json
{
  "request": "Generate exactly 5 cards",
  "categories": ["Science", "History", "Art"],
  "response_format": [
    {
      "title": "...",
      "content": "...",
      "category": "Science",
      "tags": [...],
      "difficulty": 3,
      "source": "..."
    }
  ]
}
```

**Key Requirements**:
- Explicitly request array format: `[{...}, {...}]`
- Include category field in each card
- Distribute cards across user's selected categories

## Performance Metrics

### API Call Reduction

| Scenario | Before | After | Improvement |
|----------|--------|-------|-------------|
| Daily goal: 5 cards | 5 calls | 1 call | **80% reduction** |
| Daily goal: 10 cards | 10 calls | 1 call | **90% reduction** |
| Session with 20 cards | 20 calls | 4 calls | **80% reduction** |

### User Experience

| Metric | Before | After |
|--------|--------|-------|
| Initial load time | ~2-5s (per card) | ~2-5s (all cards) |
| Time between batches | 2-5s (loading) | **Instant** (prefetched) |
| Waiting during session | Yes (each card) | **No** (background prefetch) |

### Cost Optimization

**API Cost Comparison** (Gemini 2.0 Flash):
- Input: $0.075 per 1M tokens
- Output: $0.30 per 1M tokens

**Before** (5 cards, 5 API calls):
- Input: 5 × 300 tokens = 1,500 tokens
- Output: 5 × 600 tokens = 3,000 tokens
- **Cost**: ~$0.0012

**After** (5 cards, 1 API call):
- Input: 1 × 400 tokens = 400 tokens
- Output: 1 × 3,000 tokens = 3,000 tokens
- **Cost**: ~$0.0009

**Savings**: ~25% cost reduction (fewer prompt tokens)

## Implementation Details

### State Management

```swift
class DailyCardsViewModel {
    @Published var cards: [Card] = []           // Current batch
    private var nextBatchCards: [Card] = []     // Prefetched batch
    private var isPrefetching: Bool = false     // Prevent duplicate fetches
}
```

### Cache Lifecycle

1. **App Launch**:
   - Check cache expiration (daily)
   - Load current batch from cache
   - Load next batch from cache
   - Start prefetching if no next batch

2. **During Session**:
   - Track card viewing progress
   - Trigger prefetch on second-to-last card
   - Update cache after each view

3. **Batch Transition**:
   - Instantly swap current ← next
   - Clear next batch
   - Start prefetching new next batch

4. **App Close**:
   - All progress saved to UserDefaults
   - Cards persist for next session

### Error Handling

**Prefetch Failures**:
- Silent fail (don't interrupt user)
- Fallback to loading state on batch end
- Retry mechanism built-in

**Cache Corruption**:
- Graceful degradation
- Clear corrupt cache
- Fetch fresh batch

## Debug Logging

### Prefetch Events

```
🔮 Prefetching next batch in background...
✅ Prefetched 5 cards for next batch
💾 Cached next batch: 5 cards
```

### Batch Transitions

```
🎉 All cards in current batch viewed!
📦 Loading prefetched next batch: 5 cards
```

### Cache Operations

```
📦 Loaded 5 remaining cards from cache (total: 5)
💾 Cached 5 cards
🗑️ Cache cleared
```

## Testing Checklist

### Manual Testing

- [ ] First app launch: Fetch batch works
- [ ] Second card viewed: No prefetch yet
- [ ] Fourth card viewed: Prefetch triggered
- [ ] Fifth card viewed: Instant batch transition
- [ ] Close and reopen app: Cache loads correctly
- [ ] Next day: Cache expired, new fetch
- [ ] Background fetch while viewing cards: No UI freeze

### Edge Cases

- [ ] Network error during prefetch: Silent fail
- [ ] App backgrounded during prefetch: Resume on foreground
- [ ] Cache corrupt: Clear and refetch
- [ ] Zero cards in batch: Error handling
- [ ] User changes categories: Invalidate cache

## Future Optimizations

1. **Adaptive Batch Sizing**:
   - Adjust batch size based on user reading speed
   - Larger batches for power users

2. **Predictive Prefetching**:
   - Analyze usage patterns
   - Prefetch earlier if user reads quickly

3. **Network-Aware Prefetching**:
   - Only prefetch on Wi-Fi
   - Skip prefetch on cellular (user setting)

4. **Multi-Batch Prefetching**:
   - Keep 2-3 batches ahead for offline mode

## Configuration

### Adjust Batch Size

```swift
// In DailyCardsViewModel
let dailyGoal = UserDefaults.standard.integer(forKey: "dailyGoal")
let cardCount = dailyGoal > 0 ? dailyGoal : 5  // Change default here
```

### Adjust Prefetch Trigger

```swift
// Current: Prefetch at second-to-last card
if cardsRemaining == 1 {
    // Prefetch
}

// Alternative: Prefetch at halfway point
if currentCardIndex >= cards.count / 2 {
    // Prefetch earlier
}
```

### Adjust Max Tokens

```swift
// In LLMCardGenerator.swift
"maxOutputTokens": 8000  // Increase for larger batches
```

## Summary

This optimization transforms the card generation experience from:
- **Sequential**: Each card loads individually
- **Blocking**: User waits between cards
- **Expensive**: Many API calls

To:
- **Batched**: All cards generated together
- **Prefetched**: Next batch ready before needed
- **Efficient**: Minimal API calls, zero waiting

**Result**: Seamless, fast, cost-effective knowledge card experience! 🚀
