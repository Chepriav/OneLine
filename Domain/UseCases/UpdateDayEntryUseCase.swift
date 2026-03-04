//
//  UpdateDayEntryUseCase.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 24/2/26.
//

import Foundation

public final class UpdateDayEntryUseCase {
    
    //MARK: - Properties
    
    let repository: DayEntryRepositoryProtocol
    
    //MARK: - Init
    
    public init(repository: DayEntryRepositoryProtocol) {
        self.repository = repository
    }
    
    @MainActor
    func execute(id: UUID, text: String, date: Date? = nil) async throws {
        guard let existingEntry = try await repository.fetchByID(id) else {
            throw DomainError.entryNotFound
        }
        
        let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !normalizedText.isEmpty else {
            throw DomainError.emptyText
        }
        
        let maxLength = 280
        guard normalizedText.count <= maxLength else {
            throw DomainError.textTooLong(maxLength: maxLength)
        }
        
        let finalDate = date ?? existingEntry.createdAt
        
        guard finalDate <= Date() else {
            throw DomainError.futureDate
        }
        
        let updatedEntry = DayEntry(
            id: existingEntry.id,
            text: normalizedText,
            createdAt: finalDate
        )
        
        try await repository.update(updatedEntry)
    }
    
}
