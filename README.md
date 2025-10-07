# DailyQuipAI - Daily Knowledge Cards

> Pick up fragments of time, light up a life of wisdom

[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)]()
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)]()
[![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2016+-blue.svg)]()
[![License](https://img.shields.io/badge/license-MIT-green.svg)]()

## Overview

DailyQuipAI is a lightweight knowledge learning iOS app that delivers 3-5 beautifully designed knowledge cards daily, helping users accumulate knowledge across multiple domains during their spare moments.

**One-line pitch**: Learn something new every day in just 3 minutes with beautiful knowledge cards.

## Features

- 📚 **Daily Knowledge Cards**: 3-5 curated cards delivered every morning
- 🎨 **Beautiful Design**: Stunning visuals with smooth 60fps animations
- 🔄 **Interactive Learning**: Flip, swipe, and engage with content
- 📖 **Personal Library**: Save and review your favorite cards
- 🎯 **Daily Quizzes**: Test your knowledge with fun challenges
- 📊 **Learning Stats**: Track your progress with beautiful visualizations
- 🏆 **Achievements**: Unlock badges as you learn
- 🌙 **Dark Mode**: Full support for light and dark themes

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Project Structure

```
DailyQuipAI/
├── App/                    # App entry point and configuration
├── Core/                   # Core business logic
│   ├── Models/            # Data models
│   ├── Storage/           # Core Data & repositories
│   ├── Networking/        # API client
│   └── Utils/             # Utilities and extensions
├── Services/              # Shared services (notifications, analytics, etc.)
├── Features/              # Feature modules
│   ├── Onboarding/       # First-time user experience
│   ├── DailyCards/       # Main card browsing feature
│   ├── Library/          # Personal knowledge library
│   ├── Quiz/             # Quiz and testing
│   ├── Statistics/       # Learning analytics
│   └── Settings/         # App settings
├── DesignSystem/         # Design tokens and reusable UI components
│   ├── Theme/            # Colors, typography, spacing
│   ├── Components/       # Reusable views
│   └── Animations/       # Animation helpers
└── Resources/            # Assets, localizations (future)
```

## Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/gleam.git
   cd gleam
   ```

2. **Open in Xcode**
   ```bash
   open DailyQuipAI.xcodeproj
   ```

3. **Build and run**
   - Select a simulator or device
   - Press `Cmd + R` to build and run

## Architecture

DailyQuipAI follows a **modular architecture** with clean separation of concerns:

- **MVVM Pattern**: ViewModels handle business logic, Views are purely declarative
- **Protocol-Oriented**: All major components are protocol-based for testability
- **Dependency Injection**: Dependencies injected via initializers or environment
- **Repository Pattern**: Data access abstracted behind repository protocols

For detailed architecture documentation, see [MODULE_INTERFACES.md](MODULE_INTERFACES.md).

## Development Guidelines

- **Language**: English only (i18n planned for Phase 2)
- **Testing**: Minimum 80% code coverage required
- **TDD**: Write tests before or during implementation
- **No Mock Data in Production**: All fallbacks forbidden (see [claude.md](claude.md))
- **Milestone-Based**: Every feature must pass defined acceptance criteria

See [claude.md](claude.md) for complete development guidelines.

## Testing

```bash
# Run unit tests
Cmd + U

# Run UI tests
Cmd + Shift + U

# View test coverage
Cmd + 9 → Test Navigator → Coverage
```

## Roadmap

- **v1.0 (MVP)** - Core card experience (6-8 weeks)
  - Daily cards with beautiful animations
  - Personal library
  - Basic quiz system
  - Learning statistics

- **v1.5** - Enhanced features (4-6 weeks)
  - Advanced quiz modes
  - Spaced repetition review
  - Achievement system
  - Dark mode

- **v2.0** - Social features (8-10 weeks)
  - Friends system
  - Leaderboards
  - Card sharing
  - UGC content

- **v3.0** - AI-powered (10-12 weeks)
  - AI knowledge assistant
  - Personalized learning paths
  - Voice narration
  - Multi-language support

See [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md) for detailed milestones.

## Pricing

- **Free**: 3 cards/day, basic features
- **Pro Monthly**: $0.99/month - 5-8 cards/day, all features
- **Pro Annual**: $7.99/year - Save 17%
- **Lifetime**: $12.99 - One-time purchase

## Contributing

This is currently a private project. Contributions are not being accepted at this time.

## License

Copyright © 2025 DailyQuipAI. All rights reserved.

## Documentation

- [Product Requirements](knowledge_cards_prd.md)
- [Development Plan](DEVELOPMENT_PLAN.md)
- [Module Interfaces](MODULE_INTERFACES.md)
- [Development Guidelines](claude.md)

## Contact

For questions or feedback, please open an issue.

---

**Built with ❤️ using SwiftUI**
