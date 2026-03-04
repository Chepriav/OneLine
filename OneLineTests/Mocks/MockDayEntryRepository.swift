//
//  MockDayEntryRepository.swift
//  OneLineTests
//
//  Created by Carlos Hernandez Prieto on 26/2/26.
//

import Foundation
@testable import OneLine

@MainActor
final class MockDayEntryRepository: DayEntryRepositoryProtocol {
    
    //MARK: - Spies
    
    var saveCalled = false
    var saveCallCount = 0
    var lastSavedEntry: DayEntry?
    
    var updateCalled = false
    var lastUpdatedEntry: DayEntry?
    
    var fetchAllCalled = false
    var fetchAllCallCount = 0
    
    var deleteCalled = false
    var lastDeletedEntry: DayEntry?
    
    var fetchByIDCalled = false
    var lastFetchedID: UUID?
    
    //MARK: - Stubs
    
    var entriesToReturn: [DayEntry] = []
    var entryToReturnByID: DayEntry?
    
    //MARK: Error Simulation
    
    var shouldThrowError = false
    var errorToThrow: Error = DomainError.entryNotFound
    
    //MARK: - Protocol Implementatio
    
    func save(_ entry: DayEntry) async throws {
            saveCalled = true
            saveCallCount += 1
            lastSavedEntry = entry
            
            if shouldThrowError {
                throw errorToThrow
            }
        }
        
        func update(_ entry: DayEntry) async throws {
            updateCalled = true
            lastUpdatedEntry = entry
            
            if shouldThrowError {
                throw errorToThrow
            }
        }
        
        func fetchAll() async throws -> [DayEntry] {
            fetchAllCalled = true
            fetchAllCallCount += 1
            
            if shouldThrowError {
                throw errorToThrow
            }
            
            return entriesToReturn
        }
        
        func delete(_ entry: DayEntry) async throws {
            deleteCalled = true
            lastDeletedEntry = entry
            
            if shouldThrowError {
                throw errorToThrow
            }
        }
        
        func fetchByID(_ id: UUID) async throws -> DayEntry? {
            fetchByIDCalled = true
            lastFetchedID = id
            
            if shouldThrowError {
                throw errorToThrow
            }
            
            return entryToReturnByID
        }
        
        // MARK: - Reset (para limpiar entre tests)
        
        func reset() {
            saveCalled = false
            saveCallCount = 0
            lastSavedEntry = nil
            
            updateCalled = false
            lastUpdatedEntry = nil
            
            fetchAllCalled = false
            fetchAllCallCount = 0
            
            deleteCalled = false
            lastDeletedEntry = nil
            
            fetchByIDCalled = false
            lastFetchedID = nil
            
            entriesToReturn = []
            entryToReturnByID = nil
            
            shouldThrowError = false
        }
    }
