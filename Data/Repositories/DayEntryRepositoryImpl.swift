//
//  DayEntryRepositoryImpl.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 24/2/26.
//

import Foundation

enum RepositoryError: Error, LocalizedError {
    case entityNotFound
    case mappingFailed
    
    var errorDescription: String? {
        switch self {
        case .entityNotFound:
            return "La entrada no existe"
        case .mappingFailed:
            return "Error al convertir datos"
        }
    }
}

@MainActor
final class DayEntryRepositoryImpl: DayEntryRepositoryProtocol {
    
    //MARK: - Properties
    
    private let dataSource: LocalSwiftDataSource
    
    //MARK: - Init
    
    init(dataSource: LocalSwiftDataSource) {
        self.dataSource = dataSource
    }
    
    //MARK: - Protocol
    
    func save(_ dayEntry: DayEntry) async throws {
        let entity = DayEntryMapper.toEntity(dayEntry)
        try await self.dataSource.insert(entity)
    }
    
    func fetchAll() async throws -> [DayEntry] {
        let entities = try await self.dataSource.fetchAll()
        return entities.map(DayEntryMapper.toDomain)
    }
    
    func delete(_ dayEntry: DayEntry) async throws {
        guard let entity = try await self.dataSource.fetchById(dayEntry.id) else {
            throw RepositoryError.entityNotFound
        }
        try await self.dataSource.delete(entity)
    }
    
    func fetchByID(_ id: UUID) async throws -> DayEntry? {
        guard let entity = try await self.dataSource.fetchById(id) else {
            throw RepositoryError.entityNotFound
        }
        
        return DayEntryMapper.toDomain(entity)
    }
    
    func update(_ dayEntry: DayEntry) async throws {
        guard let existingEntity = try await self.dataSource.fetchById(dayEntry.id) else {
            throw RepositoryError.entityNotFound
        }
        
        existingEntity.text = dayEntry.text
        existingEntity.createdAt = dayEntry.createdAt
        
        try await dataSource.save()
    }
}
