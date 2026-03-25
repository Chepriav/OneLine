import SwiftUI
import SwiftData

@main
struct OneLineApp: App {
    
    // MARK: - SwiftData Container
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DayEntryEntity.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: makeHomeViewModel())
        }
        .modelContainer(sharedModelContainer)
    }
    
    // MARK: - Dependency Injection
    
    @MainActor
    private func makeHomeViewModel() -> HomeViewModel {
        let modelContext = sharedModelContainer.mainContext
        let dataSource = LocalSwiftDataSource(modelContext: modelContext)
        let repository = DayEntryRepositoryImpl(dataSource: dataSource)
        let saveUseCase = SaveDayEntryUseCase(repository: repository)
        
        return HomeViewModel(saveUseCase: saveUseCase)
    }
}
