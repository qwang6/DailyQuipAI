# DailyQuipAI - Module Interfaces & Dependencies

## Overview
This document defines the public interfaces (protocols/APIs) for each module and their dependencies. Following these interfaces ensures loose coupling and testability.

---

## Module Dependency Graph

```
┌─────────────────────────────────────────────────┐
│                  App Layer                      │
│  (Onboarding, DailyCards, Library, Quiz, etc.) │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│              Services Layer                     │
│  (Notification, Analytics, Subscription, Sync)  │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│            Core Foundation                      │
│  (Models, Storage, Networking, Utils)           │
└─────────────────────────────────────────────────┘
```

**Rules**:
- Lower layers NEVER depend on upper layers
- Feature modules should NOT depend on each other
- All cross-module communication via protocols
- Services layer provides shared functionality

---

## Module 1: Core Foundation

### 1.1 Models (Domain Layer)

#### Card Model
```swift
struct Card: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let category: Category
    let frontImageURL: URL
    let backContent: String
    let tags: [String]
    let source: String
    let difficulty: Int // 1-5
    let estimatedReadTime: Int // seconds
    let createdAt: Date

    // Mock data for testing
    static func mock() -> Card
    static func mockArray(count: Int) -> [Card]
}

enum Category: String, Codable, CaseIterable {
    case history = "History"
    case science = "Science"
    case art = "Art"
    case life = "Life"
    case finance = "Finance"
    case philosophy = "Philosophy"

    var icon: String // SF Symbol name
    var color: Color
    var description: String
}
```

#### User Model
```swift
struct User: Identifiable, Codable {
    let id: UUID
    var username: String
    var email: String
    var interests: [Category]
    var streak: Int
    var totalCardsLearned: Int
    var settings: UserSettings
    var createdAt: Date

    mutating func incrementStreak()
    mutating func resetStreak()
    mutating func addCardLearned()
}

struct UserSettings: Codable {
    var notificationTime: Date
    var notificationEnabled: Bool
    var theme: Theme
    var dailyGoal: Int
}

enum Theme: String, Codable {
    case system, light, dark
}
```

#### Achievement Model
```swift
struct Achievement: Identifiable, Codable {
    let id: UUID
    let type: AchievementType
    let title: String
    let description: String
    let iconName: String
    let unlockedAt: Date?

    var isUnlocked: Bool { unlockedAt != nil }
}

enum AchievementType: String, Codable {
    case streak7, streak30, streak100
    case cards50, cards100, cards365
    case categoryExpert
    case perfectQuiz
}
```

#### Quiz Models
```swift
struct QuizQuestion: Identifiable, Codable {
    let id: UUID
    let cardID: UUID
    let questionText: String
    let type: QuestionType
    let options: [String]? // For multiple choice
    let correctAnswer: String
    let explanation: String
}

enum QuestionType: String, Codable {
    case multipleChoice
    case trueFalse
    case fillInBlank
}

struct QuizResult: Codable {
    let quizID: UUID
    let score: Int
    let totalQuestions: Int
    let completedAt: Date
    let wrongAnswers: [QuizQuestion]
}
```

---

### 1.2 Storage Layer

#### Repository Protocol
```swift
protocol CardRepository {
    func fetchDailyCards() async throws -> [Card]
    func fetchCard(id: UUID) async throws -> Card
    func saveCard(_ card: Card) async throws
    func deleteCard(id: UUID) async throws
    func fetchSavedCards() async throws -> [Card]
    func isCardSaved(id: UUID) async -> Bool
}

protocol UserRepository {
    func fetchUser() async throws -> User
    func saveUser(_ user: User) async throws
    func updateSettings(_ settings: UserSettings) async throws
}

protocol QuizRepository {
    func fetchQuestions(for cards: [Card]) async throws -> [QuizQuestion]
    func saveQuizResult(_ result: QuizResult) async throws
    func fetchWrongAnswers() async throws -> [QuizQuestion]
    func markAnswerAsLearned(questionID: UUID) async throws
}
```

#### Core Data Stack
```swift
class CoreDataStack {
    static let shared = CoreDataStack()

    let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext { persistentContainer.viewContext }

    func saveContext() throws
    func backgroundContext() -> NSManagedObjectContext
}
```

---

### 1.3 Networking Layer

#### API Client Protocol
```swift
protocol APIClient {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

enum APIEndpoint {
    case dailyCards(categories: [Category])
    case card(id: UUID)
    case createUser(User)
    case updateUser(User)
    case quizQuestions(cardIDs: [UUID])

    var path: String { get }
    var method: HTTPMethod { get }
    var body: Encodable? { get }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(statusCode: Int)
    case networkUnavailable
}
```

#### API Client Implementation
```swift
class URLSessionAPIClient: APIClient {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL, session: URLSession = .shared)

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

// Mock for testing/offline development
class MockAPIClient: APIClient {
    var shouldFail: Bool = false
    var mockDelay: TimeInterval = 0.5

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}
```

---

## Module 2: Services Layer

### 2.1 Notification Service

```swift
protocol NotificationServiceProtocol {
    func requestAuthorization() async throws -> Bool
    func scheduleDailyReminder(at time: Date) async throws
    func scheduleReviewReminder(for cards: [Card]) async throws
    func scheduleStreakWarning() async throws
    func cancelAllNotifications()
    func handleNotificationTap(_ userInfo: [AnyHashable: Any])
}

class NotificationService: NotificationServiceProtocol {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()

    // Implementation
}
```

---

### 2.2 Analytics Service

```swift
protocol AnalyticsServiceProtocol {
    func logEvent(_ event: AnalyticsEvent)
    func setUserProperty(key: String, value: String)
    func logScreenView(screenName: String)
}

enum AnalyticsEvent {
    case cardViewed(cardID: UUID, category: Category)
    case cardSaved(cardID: UUID)
    case cardShared(cardID: UUID)
    case quizCompleted(score: Int, total: Int)
    case achievementUnlocked(type: AchievementType)
    case streakIncreased(days: Int)
}

class AnalyticsService: AnalyticsServiceProtocol {
    static let shared = AnalyticsService()

    // Firebase Analytics or custom implementation
}
```

---

### 2.3 Subscription Service (IAP)

```swift
protocol SubscriptionServiceProtocol {
    var currentSubscription: SubscriptionTier { get }

    func fetchProducts() async throws -> [Product]
    func purchase(_ product: Product) async throws -> SubscriptionTier
    func restorePurchases() async throws -> SubscriptionTier
    func checkSubscriptionStatus() async -> SubscriptionTier
}

enum SubscriptionTier: String, Codable {
    case free
    case monthly
    case annual
    case lifetime

    var displayName: String { get }
    var price: String { get }
    var features: [String] { get }
}

class SubscriptionService: SubscriptionServiceProtocol {
    static let shared = SubscriptionService()

    // StoreKit 2 implementation
}
```

---

### 2.4 Sync Service (iCloud)

```swift
protocol SyncServiceProtocol {
    func enableSync() async throws
    func syncUserData() async throws
    func syncSavedCards() async throws
    var isSyncEnabled: Bool { get }
}

class SyncService: SyncServiceProtocol {
    static let shared = SyncService()

    // CloudKit implementation (Pro feature)
}
```

---

## Module 3: Feature Modules

### 3.1 Onboarding Module

#### Public Interface
```swift
// Entry point
struct OnboardingView: View {
    @Binding var isCompleted: Bool

    var body: some View
}

// Internal view models
class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var selectedCategories: Set<Category> = []
    @Published var notificationTime: Date = Date()

    func completeOnboarding() async
}
```

#### Dependencies
- Core Foundation (Models, Storage)
- Services (NotificationService)
- Design System (UI components)

---

### 3.2 Daily Cards Module

#### Public Interface
```swift
struct DailyCardsView: View {
    var body: some View
}

class DailyCardsViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var currentIndex: Int = 0
    @Published var isLoading: Bool = false
    @Published var error: Error?

    private let cardRepository: CardRepository
    private let userRepository: UserRepository
    private let analyticsService: AnalyticsServiceProtocol

    init(cardRepository: CardRepository,
         userRepository: UserRepository,
         analyticsService: AnalyticsServiceProtocol)

    func loadDailyCards() async
    func handleSwipe(direction: SwipeDirection, card: Card) async
    func shareCard(_ card: Card)
}

enum SwipeDirection {
    case left  // learned
    case right // save
    case up    // share
    case down  // details
}
```

#### Dependencies
- Core Foundation (Models, Storage, Networking)
- Services (AnalyticsService)
- Design System (CardView, animations)

---

### 3.3 Knowledge Library Module

#### Public Interface
```swift
struct KnowledgeLibraryView: View {
    var body: some View
}

class LibraryViewModel: ObservableObject {
    @Published var savedCards: [Card] = []
    @Published var viewMode: ViewMode = .timeline
    @Published var searchText: String = ""
    @Published var selectedCategory: Category?

    private let cardRepository: CardRepository

    init(cardRepository: CardRepository)

    func loadSavedCards() async
    func removeCard(id: UUID) async
    func startReviewMode() -> [Card]
}

enum ViewMode {
    case timeline, category, grid, list
}
```

#### Dependencies
- Core Foundation (Models, Storage)
- Design System (CardView)

---

### 3.4 Quiz Module

#### Public Interface
```swift
struct QuizView: View {
    let questions: [QuizQuestion]
    @Binding var isPresented: Bool

    var body: some View
}

class QuizViewModel: ObservableObject {
    @Published var questions: [QuizQuestion] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var score: Int = 0
    @Published var timeRemaining: Int = 10
    @Published var quizCompleted: Bool = false

    private let quizRepository: QuizRepository
    private let analyticsService: AnalyticsServiceProtocol

    init(quizRepository: QuizRepository,
         analyticsService: AnalyticsServiceProtocol)

    func generateQuiz(from cards: [Card]) async
    func submitAnswer(_ answer: String) async
    func completeQuiz() async
}
```

#### Dependencies
- Core Foundation (Models, Storage)
- Services (AnalyticsService)
- Design System

---

### 3.5 Statistics Module

#### Public Interface
```swift
struct StatisticsView: View {
    var body: some View
}

class StatisticsViewModel: ObservableObject {
    @Published var user: User?
    @Published var categoryDistribution: [Category: Int] = [:]
    @Published var weeklyProgress: [Date: Int] = [:]
    @Published var achievements: [Achievement] = []

    private let userRepository: UserRepository
    private let cardRepository: CardRepository

    init(userRepository: UserRepository,
         cardRepository: CardRepository)

    func loadStatistics() async
    func checkAchievements() async -> [Achievement]
}
```

#### Dependencies
- Core Foundation (Models, Storage)
- Services (AnalyticsService)

---

### 3.6 Settings Module

#### Public Interface
```swift
struct SettingsView: View {
    var body: some View
}

class SettingsViewModel: ObservableObject {
    @Published var settings: UserSettings
    @Published var subscriptionTier: SubscriptionTier = .free

    private let userRepository: UserRepository
    private let subscriptionService: SubscriptionServiceProtocol
    private let notificationService: NotificationServiceProtocol

    init(userRepository: UserRepository,
         subscriptionService: SubscriptionServiceProtocol,
         notificationService: NotificationServiceProtocol)

    func updateSettings(_ settings: UserSettings) async
    func purchaseSubscription(_ tier: SubscriptionTier) async throws
    func restorePurchases() async throws
}
```

#### Dependencies
- Core Foundation (Models, Storage)
- Services (SubscriptionService, NotificationService, SyncService)

---

## Dependency Injection

### App-level Container
```swift
class DependencyContainer {
    // Core
    let coreDataStack: CoreDataStack
    let apiClient: APIClient

    // Repositories
    let cardRepository: CardRepository
    let userRepository: UserRepository
    let quizRepository: QuizRepository

    // Services
    let notificationService: NotificationServiceProtocol
    let analyticsService: AnalyticsServiceProtocol
    let subscriptionService: SubscriptionServiceProtocol
    let syncService: SyncServiceProtocol

    init(environment: Environment = .production) {
        // Initialize all dependencies
        // Use mocks for testing environment
    }

    enum Environment {
        case production
        case development
        case testing
    }
}
```

### Usage in App
```swift
@main
struct DailyQuipAIApp: App {
    let container = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container)
        }
    }
}
```

### Usage in Views
```swift
struct DailyCardsView: View {
    @EnvironmentObject var container: DependencyContainer
    @StateObject private var viewModel: DailyCardsViewModel

    init() {
        // Inject dependencies via environment
    }
}
```

---

## Testing Protocols

### Mock Implementations
Each protocol should have a mock implementation for testing:

```swift
// Example: Mock Card Repository
class MockCardRepository: CardRepository {
    var mockDailyCards: [Card] = []
    var mockSavedCards: [Card] = []
    var shouldThrowError: Bool = false

    func fetchDailyCards() async throws -> [Card] {
        if shouldThrowError { throw NetworkError.serverError(statusCode: 500) }
        return mockDailyCards
    }

    // ... other methods
}
```

### Test Dependency Container
```swift
class TestDependencyContainer: DependencyContainer {
    override init(environment: Environment = .testing) {
        super.init(environment: environment)

        // Override with mock implementations
        apiClient = MockAPIClient()
        cardRepository = MockCardRepository()
        // ... etc
    }
}
```

---

## Module Communication Patterns

### 1. Protocol-Based Communication
✅ **DO**: Define protocols for all public interfaces
✅ **DO**: Inject dependencies via initializers or environment
❌ **DON'T**: Use singletons except for services
❌ **DON'T**: Create direct dependencies between feature modules

### 2. Event-Driven Communication
For loosely coupled events (e.g., achievement unlocked):

```swift
protocol EventBus {
    func publish(_ event: AppEvent)
    func subscribe<T: AppEvent>(_ eventType: T.Type, handler: @escaping (T) -> Void)
}

enum AppEvent {
    case cardLearned(Card)
    case streakIncreased(Int)
    case achievementUnlocked(Achievement)
}
```

### 3. Delegate Pattern
For parent-child view communication:

```swift
protocol QuizDelegate: AnyObject {
    func quizDidComplete(result: QuizResult)
}
```

---

## File Organization

```
DailyQuipAI/
├── App/
│   ├── DailyQuipAIApp.swift
│   ├── DependencyContainer.swift
│   └── Environment.swift
│
├── Core/
│   ├── Models/
│   │   ├── Card.swift
│   │   ├── User.swift
│   │   ├── Achievement.swift
│   │   └── Quiz.swift
│   ├── Storage/
│   │   ├── CoreDataStack.swift
│   │   ├── Repositories/
│   │   │   ├── CardRepository.swift
│   │   │   ├── UserRepository.swift
│   │   │   └── QuizRepository.swift
│   │   └── CoreData/
│   │       └── DailyQuipAIModel.xcdatamodeld
│   ├── Networking/
│   │   ├── APIClient.swift
│   │   ├── APIEndpoint.swift
│   │   └── NetworkError.swift
│   └── Utils/
│       ├── Extensions/
│       └── Helpers/
│
├── Services/
│   ├── NotificationService.swift
│   ├── AnalyticsService.swift
│   ├── SubscriptionService.swift
│   └── SyncService.swift
│
├── Features/
│   ├── Onboarding/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── OnboardingCoordinator.swift
│   ├── DailyCards/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Components/
│   ├── Library/
│   ├── Quiz/
│   ├── Statistics/
│   └── Settings/
│
├── DesignSystem/
│   ├── Theme/
│   │   ├── Colors.swift
│   │   ├── Typography.swift
│   │   └── Spacing.swift
│   ├── Components/
│   │   ├── CardView.swift
│   │   ├── Buttons.swift
│   │   └── EmptyState.swift
│   └── Animations/
│
└── Tests/
    ├── UnitTests/
    ├── IntegrationTests/
    └── UITests/
```

---

## Next Steps for Implementation

1. **Start with Core Foundation** (Module 1)
   - Implement all models first
   - Then storage layer with protocols
   - Then networking layer
   - Mock implementations for testing

2. **Build Design System** (Module 2)
   - Define theme and tokens
   - Create reusable components
   - Test in isolation (SwiftUI Previews)

3. **Implement Features One by One**
   - Follow milestone order
   - Each feature gets its own branch
   - Merge only after passing all tests

4. **Maintain Test Coverage**
   - Write tests alongside implementation
   - Minimum 80% coverage per module
   - Run tests before every commit

---

**Document Version**: 1.0
**Last Updated**: 2025-10-04
