//
//  EntryListViewModel.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 4/3/26.
//

import Foundation
import Observation


/// ViewModel para la lista de entradas
@MainActor
@Observable
final class EntryListViewModel {
    // MARK: - Published State
    
    var entries: [DayEntry] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var showError: Bool = false
    
    // MARK: - Dependencies
    
    private let fetchUseCase: FetchAllEntriesUseCase
    private let deleteUseCase: DeleteDayEntryUseCase
    
    // MARK: - Init

    init(
        fetchUseCase: FetchAllEntriesUseCase,
        deleteUseCase: DeleteDayEntryUseCase
    ) {
        self.fetchUseCase = fetchUseCase
        self.deleteUseCase = deleteUseCase
    }
    
    //MARK: - Actions
    
    func loadEntries() async {
        isLoading = true
        defer { self.isLoading = false }
        
        do {
            self.entries = try await fetchUseCase.execute()
        } catch {
            self.errorMessage = "Error al cargar entradas: \(error.localizedDescription)"
            self.showError = true
        }
    }
    
    func delete(_ entry: DayEntry) async {
        do {
            try await deleteUseCase.execute(entry)
            self.entries.removeAll { $0.id == entry.id }
        } catch let error as DomainError {
            errorMessage = error.errorDescription
            showError = true
        } catch {
            errorMessage = "Error al eliminar: \(error.localizedDescription)"
            showError = true
        }
    }
}
