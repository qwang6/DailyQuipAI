# DailyQuipAI Development Guidelines

## 🚨 CRITICAL SECURITY RULE - API KEY PROTECTION

### ⚠️ NEVER UPLOAD GEMINI API KEY TO GITHUB - EVER!!!

**ABSOLUTE PROHIBITION:**
- ❌ **NEVER** commit API keys to any file tracked by git
- ❌ **NEVER** include API keys in .swift files
- ❌ **NEVER** include API keys in .xcscheme files
- ❌ **NEVER** include API keys in .md documentation files
- ❌ **NEVER** include API keys in any file that goes to GitHub

**API Key Storage Rules:**
- ✅ API keys ONLY in `.env` file (local, in .gitignore)
- ✅ API keys ONLY in environment variables (runtime)
- ✅ ALWAYS verify `.env` is in `.gitignore`
- ✅ ALWAYS check `git diff` before commit for any "AIzaSy" strings

**Pre-Commit Checklist:**
```bash
# 1. Search for API keys in staged files
git diff --cached | grep -i "AIzaSy" && echo "⚠️ API KEY FOUND!" || echo "✅ Safe"

# 2. Verify .env is ignored
git status | grep ".env" && echo "⚠️ .env is tracked!" || echo "✅ Safe"

# 3. Check xcscheme files have empty API key field
grep -r "AIzaSy" *.xcscheme && echo "⚠️ API KEY in xcscheme!" || echo "✅ Safe"
```

**If API Key is Accidentally Committed:**
1. Immediately revoke the exposed key in Google Cloud Console
2. Create a new API key
3. Update local `.env` file with new key
4. `git reset --soft HEAD~1` to undo commit
5. Remove key from files
6. Recommit without key
7. `git push --force` to overwrite GitHub history

**REMEMBER: Once an API key touches GitHub, consider it compromised forever!**

---

## Target Market & Localization

### Primary Target Audience
- **Geographic Focus**: Western markets (US, EU, etc.) + overseas Chinese communities
- **Language Strategy**:
  - **Phase 1 (Current Development)**: English ONLY
    - All UI text must be in English
    - All code comments must be in English
    - All documentation must be in English
    - All user-facing content must be in English
  - **Phase 2 (Post-Launch)**: Consider internationalization (i18n) with multiple language support

### Pricing & Monetization
- **Currency**: USD (United States Dollar)
- **Pricing Tiers**:
  - Monthly subscription: $0.99/month
  - Annual subscription: $7.99/year (~17% savings)
  - Lifetime membership: $12.99

## Development Principles
1. Build with English-first mindset
2. Use proper localization keys for future i18n support
3. Avoid hardcoded strings - prepare for easy translation later
4. Design with international users in mind (avoid China-specific references)
5. Use international date/time formats
6. Support multiple currencies in backend architecture (even if only USD is active initially)

## Important Notes
- Do NOT implement Chinese language features during initial development
- Do NOT add i18n/localization in MVP - keep it simple
- Focus on clean English UX that resonates with Western users
- Consider cultural differences in design and content (e.g., examples, references, imagery)

---

## ⚠️ MANDATORY DEVELOPMENT PROTOCOL (IRON LAW)

### Modular Development Architecture
**ALL development MUST follow modular design principles:**
- Each feature must be designed as an independent, reusable module
- Modules must have clear interfaces and minimal coupling
- Each module must be independently testable
- Follow SOLID principles and clean architecture patterns

### Milestone-Based Development (STRICT REQUIREMENT)
**Every module MUST have clearly defined milestones with the following criteria:**

#### Milestone Requirements
1. **Controllable (可控)**:
   - Clear scope definition - what is IN and what is OUT
   - Defined inputs and outputs
   - Explicit dependencies listed
   - Estimated time range (min-max)
   - Assigned owner/responsible party

2. **Testable (可测)**:
   - Unit tests for all business logic (minimum 80% coverage)
   - Integration tests for module interactions
   - UI tests for user-facing features
   - Acceptance criteria that can be objectively verified
   - Test data and test scenarios defined upfront

3. **Deliverable**:
   - Each milestone must produce a working, demonstrable feature
   - Must pass all defined tests
   - Code review completed
   - Documentation updated

#### Milestone Sign-off Checklist
Before marking ANY milestone as complete, verify:
- [ ] All acceptance criteria met
- [ ] Unit tests written and passing (≥80% coverage)
- [ ] Integration tests passing
- [ ] UI tests passing (for UI features)
- [ ] Code reviewed and approved
- [ ] Documentation updated
- [ ] No known critical bugs
- [ ] Performance benchmarks met (if applicable)

### Module Development Workflow
```
1. Design Phase
   ├─ Define module scope and boundaries
   ├─ Identify dependencies
   ├─ Design interfaces (protocols/APIs)
   ├─ Write technical specification
   └─ Break down into milestones

2. Implementation Phase (per milestone)
   ├─ Write tests FIRST (TDD approach)
   ├─ Implement feature
   ├─ Ensure tests pass
   ├─ Code review
   └─ Milestone sign-off

3. Integration Phase
   ├─ Integration testing
   ├─ System testing
   └─ User acceptance testing
```

### Enforcement
- **NO exceptions**: Every feature must follow this process
- **NO shortcuts**: Skipping tests or milestones is FORBIDDEN
- **NO "we'll test later"**: Tests are written BEFORE or DURING implementation
- Progress is measured by completed, tested milestones - not lines of code

This is a **FUNDAMENTAL REQUIREMENT** for this project. Any deviation must be explicitly documented and approved.

---

## ⚠️ CRITICAL: NO FALLBACKS OR MOCK DATA IN PRODUCTION CODE

### Strict Data Handling Policy
**ABSOLUTELY FORBIDDEN in production code:**
- ❌ NO fallback data when API fails
- ❌ NO mock/dummy data in production builds
- ❌ NO hardcoded sample data as defaults
- ❌ NO "show something when nothing is available" patterns
- ❌ NO placeholder content that pretends to be real

### What This Means

#### ❌ WRONG - Do NOT do this:
```swift
func fetchDailyCards() async throws -> [Card] {
    do {
        return try await apiClient.fetchCards()
    } catch {
        // NEVER do this - returning mock data on error
        return Card.mockArray(count: 3)
    }
}
```

#### ✅ CORRECT - Do this instead:
```swift
func fetchDailyCards() async throws -> [Card] {
    // Let the error propagate - handle it in the UI layer
    return try await apiClient.fetchCards()
}

// In ViewModel:
func loadDailyCards() async {
    do {
        cards = try await repository.fetchDailyCards()
    } catch {
        // Show error state to user - NO fake data
        self.error = error
        self.cards = [] // Empty is honest
    }
}
```

### Proper Error Handling

1. **UI Layer Response to Errors**:
   - Show clear error messages to users
   - Provide retry buttons
   - Display empty states with actionable guidance
   - Never hide failures behind fake data

2. **Testing ONLY**:
   - Mock data is ONLY for unit/UI tests
   - Use dependency injection to swap real services with mocks
   - Keep mock implementations in `Tests/` folder or `#if DEBUG` blocks
   - Never let mock data leak into production

3. **Build Configuration**:
   ```swift
   #if DEBUG
   // Mock data allowed here for SwiftUI previews and development
   extension Card {
       static func mock() -> Card { ... }
   }
   #endif
   ```

### Why This Matters
- **Integrity**: Users must see real data or know when there's a problem
- **Debugging**: Hiding errors with fake data makes bugs invisible
- **Trust**: Showing fake content destroys user trust
- **Development**: Forces us to handle all error cases properly

### Exceptions (Must be Documented)
The ONLY acceptable use of sample/mock data:
1. **SwiftUI Previews** (development only, `#if DEBUG`)
2. **Unit Tests** (in test target only)
3. **UI Tests** (in test target only)
4. **Onboarding Tutorial** (if showing example of how feature works - must be clearly labeled as "example")

Any other use of mock/fallback data is **STRICTLY PROHIBITED**.
