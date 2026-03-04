//
//  FetchAllEntriesUseCase.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 3/3/26.
//


import Foundation

/// Use Case: Obtener todas las entradas del diario
public final class FetchAllEntriesUseCase {
    
    // MARK: - Properties
    
    private let repository: DayEntryRepositoryProtocol
    
    // MARK: - Init
    
    public init(repository: DayEntryRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Execute
    
    @MainActor
    public func execute() async throws -> [DayEntry] {
        return try await repository.fetchAll()
    }
}
