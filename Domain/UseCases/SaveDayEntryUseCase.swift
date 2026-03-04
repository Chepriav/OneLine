//
//  SaveDayEntryUseCase.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 24/2/26.
//

import Foundation

public final class SaveDayEntryUseCase {
    
    // MARK: - Properties
    
    private let repository: DayEntryRepositoryProtocol
    
    // MARK: - Init
    
    public init(repository: DayEntryRepositoryProtocol) {
        self.repository = repository
    }
    
    //MARK: - Execute
    
    @MainActor
    public func execute(text: String, date: Date = Date()) async throws {
        let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !normalizedText.isEmpty else {
            throw DomainError.emptyText
        }
        
        let maxLength = 200
        
        guard normalizedText.count <= maxLength else {
            throw DomainError.textTooLong(maxLength: maxLength)
        }
        
        guard date <= Date() else {
            throw DomainError.futureDate
        }
        
        let entry = DayEntry(
            id: UUID(),
            text: normalizedText,
            createdAt: date
        )
        
        try await repository.save(entry)
    }
}
