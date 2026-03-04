//
//  OneLineApp.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 23/2/26.
//

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

    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: makeHomeViewModel())  // ← Inyecta ViewModel
        }
        .modelContainer(sharedModelContainer)
    }
    
    // MARK: - Dependency Injection Factory
    
    /// Crea el HomeViewModel con todas sus dependencias
    @MainActor
    private func makeHomeViewModel() -> HomeViewModel {
        // 1. Obtener ModelContext desde el container
        let modelContext = sharedModelContainer.mainContext
        
        // 2. Crear DataSource
        let dataSource = LocalSwiftDataSource(modelContext: modelContext)
        
        // 3. Crear Repository
        let repository = DayEntryRepositoryImpl(dataSource: dataSource)
        
        // 4. Crear UseCase
        let saveUseCase = SaveDayEntryUseCase(repository: repository)
        
        // 5. Crear ViewModel
        return HomeViewModel(saveUseCase: saveUseCase)
    }
}
