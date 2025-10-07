# DailyQuipAI - Development Plan & Modular Architecture

## Project Overview
**Product**: DailyQuipAI - Daily Knowledge Cards Learning App
**Target**: Western markets + overseas Chinese communities
**Platform**: iOS (SwiftUI)
**Language**: English only (i18n in Phase 2)
**Timeline**: MVP in 6-8 weeks

---

## Modular Architecture Design

### Core Modules

```
DailyQuipAI/
├── 1. Core Layer
│   ├── Models (Data structures)
│   ├── Networking (API client)
│   ├── Storage (Core Data + UserDefaults)
│   └── Utils (Extensions, Helpers)
│
├── 2. Feature Modules
│   ├── Authentication
│   ├── Onboarding
│   ├── DailyCards (Card display & interaction)
│   ├── KnowledgeLibrary (Personal collection)
│   ├── Quiz (Testing system)
│   ├── Stats (Learning analytics)
│   ├── Settings
│   └── Notifications
│
├── 3. UI Components
│   ├── Design System (Colors, Typography, Spacing)
│   ├── Reusable Components (Cards, Buttons, etc.)
│   └── Animations
│
└── 4. Services
    ├── NotificationService
    ├── AnalyticsService
    ├── SubscriptionService (IAP)
    └── SyncService (iCloud)
```

---

## Module Definitions & Milestones

### MODULE 1: Core Foundation
**Purpose**: Establish project structure, data models, and basic infrastructure

#### Dependencies
- None (foundational module)

#### Milestones

##### M1.1: Project Setup & Configuration
**Scope**:
- Create Xcode project with SwiftUI
- Setup folder structure following modular architecture
- Configure build schemes (Debug/Release)
- Setup .gitignore and version control
- Install essential dependencies (if any)

**Acceptance Criteria**:
- [ ] Project builds successfully on Xcode 15+
- [ ] Folder structure matches architecture diagram
- [ ] Git repository initialized with proper .gitignore
- [ ] README.md created with setup instructions

**Tests**:
- [ ] Project compiles without errors
- [ ] All build schemes work correctly

**Time Estimate**: 2-4 hours

---

##### M1.2: Data Models
**Scope**:
- Define `Card` model (id, title, category, content, images, etc.)
- Define `User` model (profile, preferences, stats)
- Define `Category` enum (History, Science, Art, Life, Finance, Philosophy)
- Define `Achievement` model
- Define `QuizQuestion` model
- Define `UserSettings` model
- Add Codable conformance for all models

**Acceptance Criteria**:
- [ ] All models defined with proper property types
- [ ] Models conform to Identifiable, Codable, Equatable
- [ ] Enums have associated values where needed
- [ ] Mock data extension created for testing

**Tests**:
- [ ] Unit tests for model encoding/decoding
- [ ] Unit tests for model equality
- [ ] Unit tests verify all required properties exist
- [ ] Mock data generation tests

**Time Estimate**: 4-6 hours

---

##### M1.3: Core Data Storage Layer
**Scope**:
- Setup Core Data stack
- Create entities for Card, User, SavedCard
- Create repository protocol and implementation
- Add CRUD operations
- Error handling

**Acceptance Criteria**:
- [ ] Core Data stack initializes correctly
- [ ] Can save/fetch/update/delete cards
- [ ] Can save/fetch user data
- [ ] Proper error handling implemented
- [ ] Thread-safe operations (background context)

**Tests**:
- [ ] Unit tests for all CRUD operations
- [ ] Test data persistence across app launches
- [ ] Test concurrent access scenarios
- [ ] Test error handling (disk full, etc.)

**Time Estimate**: 6-8 hours

---

##### M1.4: Networking Layer
**Scope**:
- Create API client using URLSession + Combine
- Define API endpoints
- Create request/response models
- Implement error handling and retry logic
- Add mock API for development

**Acceptance Criteria**:
- [ ] Can make GET/POST requests
- [ ] Proper error handling (network errors, parsing errors)
- [ ] Response models decode correctly
- [ ] Mock API service for offline development
- [ ] Request logging for debugging

**Tests**:
- [ ] Unit tests for API client methods
- [ ] Test response parsing with mock data
- [ ] Test error scenarios (404, 500, timeout)
- [ ] Test retry logic

**Time Estimate**: 8-10 hours

---

### MODULE 2: Design System & UI Components
**Purpose**: Create reusable UI components and design tokens

#### Dependencies
- Module 1 (Core Foundation)

#### Milestones

##### M2.1: Design Tokens & Theme
**Scope**:
- Define color palette (light/dark mode)
- Define typography system (SF Pro Display/Text)
- Define spacing/padding constants
- Define corner radius, shadows
- Create Theme manager for dynamic switching

**Acceptance Criteria**:
- [ ] All colors defined in Colors.swift
- [ ] Typography styles defined (Title, Body, Caption, etc.)
- [ ] Spacing system (4pt grid)
- [ ] Dark mode fully supported
- [ ] Theme accessible throughout app

**Tests**:
- [ ] Snapshot tests for all color combinations
- [ ] Verify dark mode rendering
- [ ] Test theme switching

**Time Estimate**: 4-6 hours

---

##### M2.2: Card UI Component
**Scope**:
- Create CardView SwiftUI component
- Implement flip animation (3D rotation)
- Front view (image + title + category tag)
- Back view (content + source + reading time)
- Swipe gesture recognizers (left/right/up/down)
- Haptic feedback integration

**Acceptance Criteria**:
- [ ] Card displays correctly with all content
- [ ] Flip animation is smooth (60fps)
- [ ] Swipe gestures work in all directions
- [ ] Haptic feedback triggers appropriately
- [ ] Supports dynamic type/accessibility
- [ ] Works in light and dark mode

**Tests**:
- [ ] UI tests for card display
- [ ] Test flip animation completion
- [ ] Test gesture recognizers
- [ ] Snapshot tests for front/back views
- [ ] Accessibility tests (VoiceOver)

**Time Estimate**: 10-12 hours

---

##### M2.3: Common UI Components
**Scope**:
- PrimaryButton component
- SecondaryButton component
- CategoryTag component
- ProgressIndicator (dots)
- EmptyStateView
- LoadingView
- ErrorView

**Acceptance Criteria**:
- [ ] All components are reusable and configurable
- [ ] Consistent styling across components
- [ ] Accessibility labels added
- [ ] Support for different sizes/states

**Tests**:
- [ ] Snapshot tests for each component
- [ ] Test different states (enabled/disabled/loading)
- [ ] Accessibility tests

**Time Estimate**: 6-8 hours

---

### MODULE 3: Onboarding Flow
**Purpose**: First-time user experience and setup

#### Dependencies
- Module 1 (Core Foundation)
- Module 2 (Design System)

#### Milestones

##### M3.1: Welcome Screens
**Scope**:
- Create 3-page onboarding flow
- Page 1: App value proposition
- Page 2: Interactive demo of card flip
- Page 3: Set notification preferences
- Skip/Next/Get Started buttons
- Page indicator

**Acceptance Criteria**:
- [ ] All 3 pages display correctly
- [ ] Can swipe between pages
- [ ] Can skip onboarding
- [ ] Animations are smooth
- [ ] First-launch detection works

**Tests**:
- [ ] UI tests for navigation flow
- [ ] Test skip functionality
- [ ] Test completion saves user preference
- [ ] Snapshot tests for each page

**Time Estimate**: 6-8 hours

---

##### M3.2: Interest Selection
**Scope**:
- Display 6 categories with icons/descriptions
- Multi-select interface (minimum 2 required)
- Save selections to user preferences
- Animate transitions

**Acceptance Criteria**:
- [ ] All 6 categories displayed
- [ ] Can select/deselect categories
- [ ] Validation for minimum 2 selections
- [ ] Preferences saved correctly
- [ ] Continue button enabled when valid

**Tests**:
- [ ] UI tests for selection interaction
- [ ] Test validation logic
- [ ] Test preference persistence
- [ ] Snapshot tests

**Time Estimate**: 4-6 hours

---

##### M3.3: Notification Permission
**Scope**:
- Request notification permission
- Allow user to set preferred time
- Handle permission granted/denied states
- Save settings

**Acceptance Criteria**:
- [ ] Permission request displays correctly
- [ ] Time picker works
- [ ] Handles all permission states
- [ ] Settings saved correctly
- [ ] Can skip this step

**Tests**:
- [ ] UI tests for permission flow
- [ ] Test time selection
- [ ] Test granted/denied scenarios
- [ ] Integration test with NotificationService

**Time Estimate**: 4-6 hours

---

### MODULE 4: Daily Cards Feature
**Purpose**: Core card browsing and learning experience

#### Dependencies
- Module 1 (Core Foundation)
- Module 2 (Design System)

#### Milestones

##### M4.1: Card Feed View
**Scope**:
- Main screen displaying today's cards (3-5 cards)
- Swipe navigation between cards
- Progress indicator (1/3, 2/3, etc.)
- Pull to refresh
- Empty state for no cards

**Acceptance Criteria**:
- [ ] Cards load and display correctly
- [ ] Swipe navigation works smoothly
- [ ] Progress indicator updates
- [ ] Pull to refresh fetches new cards
- [ ] Empty state displays when no cards available
- [ ] Loading state while fetching

**Tests**:
- [ ] UI tests for card navigation
- [ ] Test refresh functionality
- [ ] Test empty state rendering
- [ ] Integration test with API
- [ ] Performance test (60fps scrolling)

**Time Estimate**: 8-10 hours

---

##### M4.2: Card Interaction Logic
**Scope**:
- Left swipe → Mark as learned, next card
- Right swipe → Save to library, next card
- Up swipe → Share card
- Down swipe → View details/related content
- Completion tracking
- Streak calculation

**Acceptance Criteria**:
- [ ] All swipe gestures work correctly
- [ ] Cards saved to library when right-swiped
- [ ] Learning progress tracked
- [ ] Daily streak increments
- [ ] Completion celebration animation
- [ ] Undo last action (optional)

**Tests**:
- [ ] Unit tests for swipe action handlers
- [ ] Test card save functionality
- [ ] Test streak calculation logic
- [ ] UI tests for gestures
- [ ] Integration tests with Storage

**Time Estimate**: 8-10 hours

---

##### M4.3: Card Share Feature
**Scope**:
- Generate shareable image from card
- Include card content + DailyQuipAI branding
- Share to social media (UIActivityViewController)
- Track share analytics

**Acceptance Criteria**:
- [ ] Share sheet opens correctly
- [ ] Generated image looks polished
- [ ] Includes DailyQuipAI branding/logo
- [ ] Works with all card types
- [ ] Share event tracked in analytics

**Tests**:
- [ ] Test image generation
- [ ] Snapshot tests for share image
- [ ] UI tests for share flow
- [ ] Test share cancellation

**Time Estimate**: 6-8 hours

---

### MODULE 5: Knowledge Library
**Purpose**: Personal collection and review system

#### Dependencies
- Module 1 (Core Foundation)
- Module 2 (Design System)
- Module 4 (Daily Cards - for card component reuse)

#### Milestones

##### M5.1: Library List View
**Scope**:
- Display all saved cards
- View switcher (Timeline/Category/Grid/List)
- Search functionality
- Filter by category
- Sort options (date, title, category)

**Acceptance Criteria**:
- [ ] All saved cards displayed
- [ ] All 4 view modes work correctly
- [ ] Search returns accurate results
- [ ] Filters apply correctly
- [ ] Sorting works
- [ ] Empty state for no saved cards

**Tests**:
- [ ] UI tests for view switching
- [ ] Test search functionality
- [ ] Test filter/sort logic
- [ ] Test empty state
- [ ] Performance test with 100+ cards

**Time Estimate**: 10-12 hours

---

##### M5.2: Card Detail View
**Scope**:
- Full-screen card view
- Related cards section
- Tags display
- Remove from library option
- Share from detail view

**Acceptance Criteria**:
- [ ] Card content displays fully
- [ ] Related cards load correctly
- [ ] Can remove card from library
- [ ] Share works from detail view
- [ ] Smooth animations

**Tests**:
- [ ] UI tests for detail view
- [ ] Test remove functionality
- [ ] Test related cards loading
- [ ] Snapshot tests

**Time Estimate**: 6-8 hours

---

##### M5.3: Review System (Simplified Spaced Repetition)
**Scope**:
- Calculate next review date based on algorithm
- Review mode: random card selection
- Mark card as reviewed
- Review reminder notifications
- Review progress tracking

**Acceptance Criteria**:
- [ ] Review dates calculated correctly
- [ ] Review mode shows cards due for review
- [ ] Review count updates after completion
- [ ] Notifications sent for due reviews
- [ ] Review history tracked

**Tests**:
- [ ] Unit tests for review algorithm
- [ ] Test review date calculation
- [ ] Test review mode card selection
- [ ] Integration test with notifications
- [ ] Test review history persistence

**Time Estimate**: 10-12 hours

---

### MODULE 6: Quiz System
**Purpose**: Knowledge testing and reinforcement

#### Dependencies
- Module 1 (Core Foundation)
- Module 2 (Design System)
- Module 4 (Daily Cards - for content)

#### Milestones

##### M6.1: Daily Challenge Quiz
**Scope**:
- Generate 5 questions from today's cards
- Multiple choice, true/false, fill-in-blank question types
- 10-second timer per question
- Score calculation
- Results screen with breakdown

**Acceptance Criteria**:
- [ ] Quiz generates correctly from daily cards
- [ ] All question types work
- [ ] Timer counts down correctly
- [ ] Score calculated accurately
- [ ] Results show correct/incorrect answers
- [ ] Can review wrong answers

**Tests**:
- [ ] Unit tests for question generation
- [ ] Test score calculation logic
- [ ] UI tests for quiz flow
- [ ] Test timer functionality
- [ ] Test all question types

**Time Estimate**: 10-12 hours

---

##### M6.2: Wrong Answer Bank
**Scope**:
- Save incorrectly answered questions
- Display in separate view
- Retry functionality
- Mark as mastered option
- Clear wrong answers

**Acceptance Criteria**:
- [ ] Wrong answers saved automatically
- [ ] Can view all wrong answers
- [ ] Can retry individual questions
- [ ] Can mark as mastered
- [ ] Statistics on improvement

**Tests**:
- [ ] Test wrong answer storage
- [ ] Test retry functionality
- [ ] UI tests for wrong answer view
- [ ] Test mastered state

**Time Estimate**: 6-8 hours

---

### MODULE 7: Statistics & Achievements
**Purpose**: Learning analytics and gamification

#### Dependencies
- Module 1 (Core Foundation)
- Module 2 (Design System)
- Module 4, 5, 6 (for data collection)

#### Milestones

##### M7.1: Learning Dashboard
**Scope**:
- Display key metrics (streak, total cards, saved cards)
- Category distribution pie chart
- Weekly/monthly learning trend line chart
- Daily learning time
- Visualizations using Charts framework

**Acceptance Criteria**:
- [ ] All metrics display correctly
- [ ] Charts render properly
- [ ] Data updates in real-time
- [ ] Time period switcher works
- [ ] Animations are smooth

**Tests**:
- [ ] Unit tests for metric calculations
- [ ] Test chart data transformations
- [ ] UI tests for dashboard
- [ ] Test with various data ranges
- [ ] Snapshot tests for charts

**Time Estimate**: 10-12 hours

---

##### M7.2: Achievement System
**Scope**:
- Define achievement types (streak, cards learned, categories, etc.)
- Achievement unlock logic
- Achievement badge UI
- Achievement notification/celebration
- Share achievement feature

**Acceptance Criteria**:
- [ ] Achievements unlock correctly
- [ ] Badge UI displays properly
- [ ] Celebration animation plays
- [ ] Can share achievements
- [ ] Achievement history viewable

**Tests**:
- [ ] Unit tests for unlock logic
- [ ] Test all achievement triggers
- [ ] UI tests for badge display
- [ ] Test achievement persistence
- [ ] Test edge cases (same day unlocks)

**Time Estimate**: 8-10 hours

---

### MODULE 8: Notifications
**Purpose**: Engagement and retention through timely reminders

#### Dependencies
- Module 1 (Core Foundation)

#### Milestones

##### M8.1: Notification Service
**Scope**:
- Schedule daily learning reminder
- Schedule review reminders
- Schedule streak about-to-break warning
- Handle notification permissions
- Handle notification taps (deep linking)

**Acceptance Criteria**:
- [ ] Daily notifications sent at user-specified time
- [ ] Review notifications sent when cards due
- [ ] Streak warning sent correctly
- [ ] Tapping notification opens correct screen
- [ ] Can reschedule notifications
- [ ] Handles permission changes

**Tests**:
- [ ] Unit tests for scheduling logic
- [ ] Test notification content generation
- [ ] Test deep linking handlers
- [ ] Integration test with system notifications
- [ ] Test rescheduling

**Time Estimate**: 8-10 hours

---

### MODULE 9: Settings & Profile
**Purpose**: User preferences and account management

#### Dependencies
- Module 1 (Core Foundation)
- Module 2 (Design System)

#### Milestones

##### M9.1: Settings Screen
**Scope**:
- Notification settings (time, enabled/disabled)
- Daily goal setting
- Theme selection (system/light/dark)
- Language preference (for future i18n)
- Clear cache option
- About section (version, terms, privacy)

**Acceptance Criteria**:
- [ ] All settings save correctly
- [ ] Changes apply immediately
- [ ] Validation for invalid inputs
- [ ] Settings persist across launches
- [ ] About info displays correctly

**Tests**:
- [ ] Unit tests for settings persistence
- [ ] UI tests for settings changes
- [ ] Test input validation
- [ ] Test theme switching
- [ ] Test clear cache functionality

**Time Estimate**: 6-8 hours

---

##### M9.2: Subscription Management
**Scope**:
- Display current subscription status
- Purchase flow (monthly/annual/lifetime)
- Restore purchases
- Subscription benefits comparison
- Handle payment errors

**Acceptance Criteria**:
- [ ] Subscription status displays correctly
- [ ] Can purchase all tiers ($0.99, $7.99, $12.99)
- [ ] Restore purchases works
- [ ] Payment errors handled gracefully
- [ ] Receipt validation works

**Tests**:
- [ ] Test purchase flow (sandbox)
- [ ] Test restore purchases
- [ ] Test error scenarios
- [ ] UI tests for subscription UI
- [ ] Test subscription state persistence

**Time Estimate**: 12-14 hours (IAP is complex)

---

### MODULE 10: Content Management (Backend/CMS)
**Purpose**: Admin tools for content creation (separate from iOS app)

#### Dependencies
- Module 1 (API contracts)

#### Milestones

##### M10.1: REST API Development
**Scope**:
- GET /cards/daily (returns 3-5 cards based on user preferences)
- GET /cards/:id (get single card)
- GET /categories (list categories)
- POST /users (create user)
- GET /users/:id (get user profile)
- PATCH /users/:id (update user preferences)
- Authentication endpoints

**Acceptance Criteria**:
- [ ] All endpoints functional
- [ ] Proper authentication/authorization
- [ ] Input validation
- [ ] Error responses follow standard
- [ ] API documentation (Swagger/OpenAPI)
- [ ] Rate limiting implemented

**Tests**:
- [ ] API integration tests
- [ ] Test authentication
- [ ] Test error cases (400, 401, 404, 500)
- [ ] Load testing
- [ ] Test rate limiting

**Time Estimate**: 12-16 hours

---

##### M10.2: Simple CMS for Card Creation
**Scope**:
- Web interface for creating/editing cards
- Image upload
- Rich text editor for content
- Category assignment
- Preview functionality
- Publish/draft status

**Acceptance Criteria**:
- [ ] Can create new cards via web UI
- [ ] Can edit existing cards
- [ ] Image upload works
- [ ] Preview shows accurate rendering
- [ ] Can publish/unpublish cards
- [ ] Validation prevents incomplete cards

**Tests**:
- [ ] E2E tests for card creation flow
- [ ] Test image upload
- [ ] Test validation rules
- [ ] Test publish workflow

**Time Estimate**: 16-20 hours

---

## Development Timeline & Roadmap

### Phase 1: MVP Foundation (Weeks 1-2)
**Goal**: Core infrastructure and basic UI

| Week | Modules | Milestones |
|------|---------|-----------|
| Week 1 | Module 1: Core Foundation | M1.1, M1.2, M1.3, M1.4 |
| Week 2 | Module 2: Design System & UI | M2.1, M2.2, M2.3 |

**Deliverable**:
- Project structure complete
- Data models defined
- Storage & networking functional
- Reusable UI components ready
- Card component with animations

---

### Phase 2: Core Features (Weeks 3-4)
**Goal**: Daily cards and onboarding experience

| Week | Modules | Milestones |
|------|---------|-----------|
| Week 3 | Module 3: Onboarding | M3.1, M3.2, M3.3 |
| | Module 4: Daily Cards (start) | M4.1 |
| Week 4 | Module 4: Daily Cards (finish) | M4.2, M4.3 |

**Deliverable**:
- Complete onboarding flow
- Functional daily card feed
- Card interactions working
- Share functionality

---

### Phase 3: Extended Features (Weeks 5-6)
**Goal**: Library, quiz, and engagement features

| Week | Modules | Milestones |
|------|---------|-----------|
| Week 5 | Module 5: Knowledge Library | M5.1, M5.2, M5.3 |
| | Module 6: Quiz (start) | M6.1 |
| Week 6 | Module 6: Quiz (finish) | M6.2 |
| | Module 7: Stats & Achievements | M7.1, M7.2 |

**Deliverable**:
- Personal library with review system
- Daily challenge quiz
- Wrong answer bank
- Learning dashboard
- Achievement system

---

### Phase 4: Polish & Backend (Weeks 7-8)
**Goal**: Notifications, settings, subscriptions, and content system

| Week | Modules | Milestones |
|------|---------|-----------|
| Week 7 | Module 8: Notifications | M8.1 |
| | Module 9: Settings & Profile | M9.1, M9.2 |
| Week 8 | Module 10: Backend/CMS | M10.1, M10.2 |
| | Testing & Bug Fixes | Full integration testing |

**Deliverable**:
- Notification system working
- Settings and subscription management
- Backend API functional
- CMS for content creation
- MVP ready for TestFlight

---

## Key Performance Indicators (Per Module)

### Code Quality Metrics
- **Test Coverage**: Minimum 80% for all modules
- **Build Time**: < 30 seconds for incremental builds
- **Crash-free Rate**: > 99.5%
- **App Size**: < 50 MB

### Performance Benchmarks
- **App Launch**: < 2 seconds (cold start)
- **Card Load Time**: < 0.5 seconds
- **Animation Frame Rate**: ≥ 60fps
- **Memory Usage**: < 150MB during normal use

### Module Completion Criteria
Each module is considered complete only when:
1. All milestones passed sign-off checklist
2. Code coverage ≥ 80%
3. No critical/high-priority bugs
4. Code reviewed and approved
5. Documentation updated

---

## Risk Mitigation

### Technical Risks
| Risk | Mitigation |
|------|-----------|
| Complex animations causing performance issues | Profile early, use Instruments, simplify if needed |
| IAP integration complexity | Start M9.2 early, use sandbox extensively |
| Backend delays blocking iOS dev | Use mock API service throughout development |
| Core Data migration issues | Version models from day 1, test migrations |

### Schedule Risks
| Risk | Mitigation |
|------|-----------|
| Milestone delays | Weekly reviews, adjust scope if needed |
| Scope creep | Strict adherence to PRD, defer features to v1.5 |
| Testing taking longer than expected | Parallel testing during development (TDD) |

---

## Next Steps

1. **Review and approve this plan**
2. **Setup development environment** (Xcode, Git, tools)
3. **Begin Module 1, Milestone M1.1** (Project Setup)
4. **Establish weekly sync meetings** for milestone reviews
5. **Setup CI/CD pipeline** for automated testing

---

**Document Version**: 1.0
**Last Updated**: 2025-10-04
**Next Review**: After Week 2 (adjust timeline if needed)
