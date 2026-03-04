//
//  DeleteDayEntryUseCase.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 3/3/26.
//


import Foundation

/// Use Case: Eliminar una entrada del diario
public final class DeleteDayEntryUseCase {
    
    // MARK: - Properties
    
    private let repository: DayEntryRepositoryProtocol
    
    // MARK: - Init
    
    public init(repository: DayEntryRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Execute
    
    @MainActor
    public func execute(_ entry: DayEntry) async throws {
        try await repository.delete(entry)
    }
}
