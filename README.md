# OneLine

Daily micro-journal iOS app built with Clean Architecture.

[![CI](https://github.com/Chepriav/OneLine/actions/workflows/ci.yml/badge.svg)](https://github.com/Chepriav/OneLine/actions/workflows/ci.yml)

## Tech Stack

- Swift 6 with strict concurrency
- SwiftUI + SwiftData
- Clean Architecture (Domain/Data/Presentation)
- MVVM pattern
- Comprehensive unit tests (51+ tests)
- GitHub Actions CI/CD

## Architecture
```
Domain/       # Business logic (UseCases, Models, Protocols)
Data/         # Persistence layer (SwiftData, Repositories)
Presentation/ # UI layer (Views, ViewModels)
```

## Features

- ✍️ One line daily journal entries
- 📅 Date selection
- 🌍 Localized (EN/ES)
- 🎨 Design system with tokens
- 🧪 100% test coverage on domain logic

## Running Tests
```bash
xcodebuild test -scheme OneLine -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Author

Carlos Hernández - [LinkedIn](https://linkedin.com/in/carlos-hernandez-prieto)
