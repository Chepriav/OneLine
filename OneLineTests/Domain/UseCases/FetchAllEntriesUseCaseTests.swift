//
//  FetchAllEntriesUseCaseTests.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 3/3/26.
//


import XCTest
@testable import OneLine

@MainActor
final class FetchAllEntriesUseCaseTests: XCTestCase {
    
    // MARK: - System Under Test
    
    var sut: FetchAllEntriesUseCase!
    var mockRepository: MockDayEntryRepository!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockRepository = MockDayEntryRepository()
        sut = FetchAllEntriesUseCase(repository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Success Cases
    
    func test_execute_callsRepository() async throws {
        // Given
        mockRepository.entriesToReturn = []
        
        // When
        _ = try await sut.execute()
        
        // Then
        XCTAssertTrue(mockRepository.fetchAllCalled)
        XCTAssertEqual(mockRepository.fetchAllCallCount, 1)
    }
    
    func test_execute_returnsEntriesFromRepository() async throws {
        // Given
        let entry1 = DayEntry(text: "Primera entrada", createdAt: Date())
        let entry2 = DayEntry(text: "Segunda entrada", createdAt: Date())
        mockRepository.entriesToReturn = [entry1, entry2]
        
        // When
        let entries = try await sut.execute()
        
        // Then
        XCTAssertEqual(entries.count, 2)
        XCTAssertEqual(entries[0].text, "Primera entrada")
        XCTAssertEqual(entries[1].text, "Segunda entrada")
    }
    
    func test_execute_withEmptyRepository_returnsEmptyArray() async throws {
        // Given
        mockRepository.entriesToReturn = []
        
        // When
        let entries = try await sut.execute()
        
        // Then
        XCTAssertTrue(entries.isEmpty)
    }
    
    func test_execute_preservesEntryOrder() async throws {
        // Given
        let date1 = Date()
        let date2 = date1.addingTimeInterval(-86400)  // 1 día antes
        let date3 = date1.addingTimeInterval(-172800) // 2 días antes
        
        let entry1 = DayEntry(text: "Más reciente", createdAt: date1)
        let entry2 = DayEntry(text: "Medio", createdAt: date2)
        let entry3 = DayEntry(text: "Más antigua", createdAt: date3)
        
        mockRepository.entriesToReturn = [entry1, entry2, entry3]
        
        // When
        let entries = try await sut.execute()
        
        // Then
        XCTAssertEqual(entries.count, 3)
        XCTAssertEqual(entries[0].text, "Más reciente")
        XCTAssertEqual(entries[1].text, "Medio")
        XCTAssertEqual(entries[2].text, "Más antigua")
    }
    
    // MARK: - Error Cases
    
    func test_execute_whenRepositoryFails_propagatesError() async {
        // Given
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = RepositoryError.mappingFailed
        
        // When/Then
        do {
            _ = try await sut.execute()
            XCTFail("Debería haber lanzado error")
        } catch let error as RepositoryError {
            XCTAssertEqual(error, RepositoryError.mappingFailed)
        } catch {
            XCTFail("Error incorrecto: \(error)")
        }
    }
}

