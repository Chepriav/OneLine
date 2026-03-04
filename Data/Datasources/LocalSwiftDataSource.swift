//
//  SwiftDataSource.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 24/2/26.
//

import Foundation
import SwiftData

final class LocalSwiftDataSource: DayEntryDataSourceProtocol {
    
    // MARK: - Properties
    
    private let modelContext: ModelContext
   
    // MARK: - Init
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - CRUD operations
    
    func insert (_ entity: DayEntryEntity) async throws {
        modelContext.insert(entity)
        try? modelContext.save()
    }
    
    func fetchAll() async throws -> [DayEntryEntity] {
        let descriptor = FetchDescriptor<DayEntryEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    func delete(_ entity: DayEntryEntity) async throws {
        modelContext.delete(entity)
        try? modelContext.save()
    }
    
    func fetchById(_ id: UUID) async throws -> DayEntryEntity? {
        let descriptor = FetchDescriptor<DayEntryEntity>()
        let result = try modelContext.fetch(descriptor)
        return result.first{ $0.id == id }
    }
    
    func save () async throws {
        try modelContext.save()
    }
}
