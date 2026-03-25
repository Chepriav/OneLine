# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OneLine is a daily micro-journal iOS app built with Swift 6 and Clean Architecture. Users can write one journal entry per day (max 200 characters), select dates, and view all their entries.

**Tech Stack:**
- Swift 6 with strict concurrency
- SwiftUI + SwiftData for persistence
- Clean Architecture (Domain/Data/Presentation layers)
- MVVM pattern with `@Observable` (Observation framework)
- Comprehensive unit tests (51+ tests)

## Building and Testing

### Build the project
```bash
xcodebuild -scheme OneLine -destination 'platform=iOS Simulator,name=iPhone 16'
```

### Run all tests
```bash
xcodebuild test -scheme OneLine -destination 'platform=iOS Simulator,name=iPhone 16' -enableCodeCoverage YES clean test
```

### Run specific test class
```bash
xcodebuild test -scheme OneLine -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:OneLineTests/SaveDayEntryUseCaseTests
```

### Run single test method
```bash
xcodebuild test -scheme OneLine -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:OneLineTests/SaveDayEntryUseCaseTests/testExecuteWithValidTextSavesEntry
```

## Architecture

This project uses **Hexagonal Architecture (Ports & Adapters)** with strict layer separation:

### Domain Layer (`Domain/`)
- **100% framework-independent** - no imports of SwiftUI/UIKit/SwiftData
- Contains business logic, entities, use cases, and repository protocols
- Structure:
  - `Models/` - Pure domain entities (e.g., `DayEntry`)
  - `UseCases/` - Business logic orchestration (e.g., `SaveDayEntryUseCase`, `FetchAllEntriesUseCase`)
  - `Repositories/` - Protocol definitions (ports) that Data layer implements
  - `DomainErrors/` - Typed errors (e.g., `DomainError.emptyText`, `DomainError.textTooLong`)

**Key principle:** Domain errors are typed enums, NOT localized strings. Localization happens in Presentation layer.

### Data Layer (`Data/`)
- Implements repository protocols from Domain
- Structure:
  - `Entities/` - SwiftData models (e.g., `DayEntryEntity` with `@Model`)
  - `Datasources/` - Data source protocols and implementations (e.g., `LocalSwiftDataSource`)
  - `Mappers/` - Convert between Domain models and Data entities (e.g., `DayEntryMapper`)
  - `Repositories/` - Repository implementations (e.g., `DayEntryRepositoryImpl`)

**Key principle:** All SwiftData operations must be marked `@MainActor` to ensure thread safety.

### Presentation Layer (`Presentation/`)
- SwiftUI views and ViewModels using `@Observable` (not `ObservableObject`)
- Structure:
  - `Home/` - HomeView + HomeViewModel (main entry screen)
  - `EntryList/` - EntryListView + EntryListViewModel (list all entries)
  - `Components/` - Reusable UI components (e.g., `DatePickerCard`, `EntryInputCard`)
  - `Utilities/` - Localization helpers (e.g., `L10n.swift`)

**Key principles:**
- ViewModels are `@MainActor @Observable final class`
- All async operations use `async/await`
- Error handling converts `DomainError` to localized strings

### Dependency Injection

Dependencies are manually injected via constructors in `OneLineApp.swift:38-45`:

```swift
@MainActor
private func makeHomeViewModel() -> HomeViewModel {
    let modelContext = sharedModelContainer.mainContext
    let dataSource = LocalSwiftDataSource(modelContext: modelContext)
    let repository = DayEntryRepositoryImpl(dataSource: dataSource)
    let saveUseCase = SaveDayEntryUseCase(repository: repository)
    return HomeViewModel(saveUseCase: saveUseCase)
}
```

When adding new features, follow this pattern: create data source → repository → use case → inject into ViewModel.

## Localization

**Languages:** English (base) and Spanish

**Strategy:** Using Xcode String Catalogs (`.xcstrings` files) located in `Resources/Localizable.xcstrings`

### Type-safe localization with L10n

The `Presentation/Utilities/L10n.swift` enum provides compile-time safe access to localized strings:

```swift
// Simple strings
static let homeTitle = String(localized: "home.title")

// Parameterized strings
static func errorTextTooLong(maxLength: Int) -> String {
    String(localized: "error.text_too_long", defaultValue: "Text cannot exceed \(maxLength) characters")
}
```

**Usage in ViewModels:**
```swift
errorMessage = L10n.errorTextTooLong(maxLength: 200)
```

**Usage in Views:**
```swift
Text(L10n.homeTitle)
```

**Important:** Domain layer NEVER uses localized strings. Errors are typed enums that ViewModels translate to user-facing messages.

### Adding new localized strings

1. Add the key to `Resources/Localizable.xcstrings` with English and Spanish translations
2. Add a static property or function to `L10n.swift` following existing patterns
3. Use the new `L10n` property in your View or ViewModel

## Testing Conventions

### Test Structure
- Tests mirror source structure: `OneLineTests/Domain/UseCases/`, `OneLineTests/Presentation/Home/`
- Mocks are in `OneLineTests/Mocks/` (e.g., `MockDayEntryRepository`)
- Use Swift Testing framework (`@Test`, `@Suite`, `#expect`)

### Writing Tests

**Domain Use Case Tests:**
```swift
@Test("Save entry with valid text succeeds")
func testExecuteWithValidTextSavesEntry() async throws {
    let mockRepo = MockDayEntryRepository()
    let useCase = SaveDayEntryUseCase(repository: mockRepo)

    try await useCase.execute(text: "Valid entry", date: Date())

    #expect(mockRepo.savedEntries.count == 1)
    #expect(mockRepo.savedEntries.first?.text == "Valid entry")
}
```

**ViewModel Tests:**
```swift
@MainActor
@Test("ViewModel shows error on empty text")
func testSaveEntryWithEmptyTextShowsError() async {
    let viewModel = HomeViewModel(saveUseCase: mockUseCase)
    viewModel.newEntryText = ""

    await viewModel.saveEntry()

    #expect(viewModel.showError == true)
    #expect(viewModel.errorMessage != nil)
}
```

### Running Tests in Xcode
Use Cmd+U or click the diamond next to test functions. Tests run on iPhone 16 simulator by default.

## Code Style and Conventions

### Swift Concurrency
- All repository operations are `async throws`
- ViewModels use `@MainActor` to ensure UI updates on main thread
- Use `Task.sleep(for:)` for delays (not old `sleep()`)

### Observation Framework
Use `@Observable` instead of `ObservableObject`:
```swift
@MainActor
@Observable
final class HomeViewModel {
    var newEntryText: String = ""
    var isLoading: Bool = false
    // ...
}
```

Views bind with `@State`:
```swift
struct HomeView: View {
    @State private var viewModel: HomeViewModel
    // ...
}
```

### MARK Comments
Use MARK comments to organize code:
```swift
// MARK: - Properties
// MARK: - Init
// MARK: - Protocol Implementation
// MARK: - Private Methods
```

### Error Handling
1. Domain layer throws typed `DomainError` enums
2. ViewModels catch errors and convert to localized messages:
```swift
do {
    try await useCase.execute(...)
} catch let error as DomainError {
    errorMessage = error.localizedDescription  // Uses L10n internally
    showError = true
}
```

## Design System

Located in `DesignSystem/` with design tokens and atomic components:

- `Tokens/` - `DSColors`, `DSTypography`, `DSSpacing`
- `Components/` - Reusable UI components like `PrimaryButton`, `SuccessOverlay`

When creating new UI, prefer composing existing design system components.

## Common Workflows

### Adding a new use case

1. Create use case in `Domain/UseCases/NewFeatureUseCase.swift`
2. Define protocol method in `Domain/Repositories/RepositoryProtocol.swift` if needed
3. Implement repository method in `Data/Repositories/RepositoryImpl.swift`
4. Add mapper logic if new entities are involved
5. Inject use case into ViewModel via constructor
6. Write tests in `OneLineTests/Domain/UseCases/NewFeatureUseCaseTests.swift`

### Adding a new screen

1. Create folder in `Presentation/NewScreen/`
2. Add `NewScreenView.swift` (SwiftUI view)
3. Add `NewScreenViewModel.swift` (`@Observable` class with `@MainActor`)
4. Inject dependencies in `OneLineApp.swift` or parent view
5. Add navigation logic if needed
6. Write tests in `OneLineTests/Presentation/NewScreen/`

### Modifying SwiftData schema

1. Update `Data/Entities/EntityName.swift` with new properties
2. Update `Data/Mappers/Mapper.swift` to handle new fields
3. Consider migration strategy if changing existing fields
4. Update corresponding Domain model if needed
5. Run clean build to regenerate SwiftData schema

## CI/CD

GitHub Actions workflow (`.github/workflows/ci.yml`) runs on every push/PR to main/develop:
- Builds on macOS 15 with Xcode 16
- Runs all tests with code coverage enabled
- Uses iPhone 16 simulator

Target: Maintain 100% test coverage on Domain layer, high coverage overall.

## Important Notes

- **No Coordinators yet:** Navigation is handled directly in views. The architecture document mentions Coordinators as a future goal.
- **No Core layer yet:** Cross-cutting concerns (networking, keychain) will go in a future `Core/` folder when needed.
- **SwiftData is @MainActor:** All SwiftData operations must run on main thread. Mark functions with `@MainActor` when working with `ModelContext`.
- **Domain purity:** Never import SwiftUI, UIKit, or SwiftData in Domain layer. Keep it 100% framework-independent.
- **Localization in Domain:** The current `DomainError.swift:17-31` uses `String(localized:)` which technically violates clean architecture. This is acceptable for error descriptions, but business logic should never depend on localization.
