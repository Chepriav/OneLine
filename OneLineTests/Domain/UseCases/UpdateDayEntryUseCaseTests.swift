//
//  UpdateDayEntryUseCaseTests.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 3/3/26.
//


import XCTest
@testable import OneLine

@MainActor
final class UpdateDayEntryUseCaseTests: XCTestCase {
    
    // MARK: - System Under Test
    
    var sut: UpdateDayEntryUseCase!
    var mockRepository: MockDayEntryRepository!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockRepository = MockDayEntryRepository()
        sut = UpdateDayEntryUseCase(repository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Success Cases
    
    func test_execute_withValidData_callsRepository() async throws {
        // Given
        let existingEntry = DayEntry(text: "Original", createdAt: Date())
        mockRepository.entryToReturnByID = existingEntry
        
        // When
        try await sut.execute(id: existingEntry.id, text: "Actualizado")
        
        // Then
        XCTAssertTrue(mockRepository.fetchByIDCalled)
        XCTAssertTrue(mockRepository.updateCalled)
    }
    
    func test_execute_updatesCorrectEntry() async throws {
        // Given
        let existingEntry = DayEntry(text: "Original", createdAt: Date())
        mockRepository.entryToReturnByID = existingEntry
        
        let newText = "Texto actualizado"
        
        // When
        try await sut.execute(id: existingEntry.id, text: newText)
        
        // Then
        XCTAssertNotNil(mockRepository.lastUpdatedEntry)
        XCTAssertEqual(mockRepository.lastUpdatedEntry?.id, existingEntry.id)
        XCTAssertEqual(mockRepository.lastUpdatedEntry?.text, "Texto actualizado")
    }
    
    func test_execute_trimsWhitespace() async throws {
        // Given
        let existingEntry = DayEntry(text: "Original", createdAt: Date())
        mockRepository.entryToReturnByID = existingEntry
        
        // When
        try await sut.execute(id: existingEntry.id, text: "  Actualizado  ")
        
        // Then
        XCTAssertEqual(mockRepository.lastUpdatedEntry?.text, "Actualizado")
    }
    
    func test_execute_withoutNewDate_keepsOriginalDate() async throws {
        // Given
        let originalDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let existingEntry = DayEntry(text: "Original", createdAt: originalDate)
        mockRepository.entryToReturnByID = existingEntry
        
        // When
        try await sut.execute(id: existingEntry.id, text: "Actualizado", date: nil)
        
        // Then
        let updatedDate = mockRepository.lastUpdatedEntry?.createdAt
        XCTAssertNotNil(updatedDate)
        XCTAssertEqual(updatedDate!.timeIntervalSince1970, originalDate.timeIntervalSince1970, accuracy: 1.0)
    }
    
    func test_execute_withNewDate_updatesDate() async throws {
        // Given
        let originalDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let existingEntry = DayEntry(text: "Original", createdAt: originalDate)
        mockRepository.entryToReturnByID = existingEntry
        
        let newDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        
        // When
        try await sut.execute(id: existingEntry.id, text: "Actualizado", date: newDate)
        
        // Then
        let updatedDate = mockRepository.lastUpdatedEntry?.createdAt
        XCTAssertNotNil(updatedDate)
        XCTAssertEqual(updatedDate!.timeIntervalSince1970, newDate.timeIntervalSince1970, accuracy: 1.0)
    }
    
    func test_execute_preservesEntryID() async throws {
        // Given
        let existingEntry = DayEntry(text: "Original", createdAt: Date())
        mockRepository.entryToReturnByID = existingEntry
        
        // When
        try await sut.execute(id: existingEntry.id, text: "Actualizado")
        
        // Then
        XCTAssertEqual(mockRepository.lastUpdatedEntry?.id, existingEntry.id)
    }
    
    // MARK: - Validation Error Cases
    
    func test_execute_withEmptyText_throwsEmptyTextError() async {
        // Given
        let existingEntry = DayEntry(text: "Original", createdAt: Date())
        mockRepository.entryToReturnByID = existingEntry
        
        // When/Then
        do {
            try await sut.execute(id: existingEntry.id, text: "")
            XCTFail("Debería haber lanzado error")
        } catch let error as DomainError {
            XCTAssertEqual(error, DomainError.emptyText)
        } catch {
            XCTFail("Error incorrecto: \(error)")
        }
    }
    
    func test_execute_withWhitespaceOnly_throwsEmptyTextError() async {
        // Given
        let existingEntry = DayEntry(text: "Original", createdAt: Date())
        mockRepository.entryToReturnByID = existingEntry
        
        // When/Then
        do {
            try await sut.execute(id: existingEntry.id, text: "   ")
            XCTFail("Debería haber lanzado error")
        } catch let error as DomainError {
            XCTAssertEqual(error, DomainError.emptyText)
        } catch {
            XCTFail("Error incorrecto: \(error)")
        }
    }
    
    func test_execute_withTextTooLong_throwsTextTooLongError() async {
        // Given
        let existingEntry = DayEntry(text: "Original", createdAt: Date())
        mockRepository.entryToReturnByID = existingEntry
        
        let longText = String(repeating: "a", count: 281)
        
        // When/Then
        do {
            try await sut.execute(id: existingEntry.id, text: longText)
            XCTFail("Debería haber lanzado error")
        } catch let error as DomainError {
            if case .textTooLong(let maxLength) = error {
                XCTAssertEqual(maxLength, 280)
            } else {
                XCTFail("Error incorrecto: \(error)")
            }
        } catch {
            XCTFail("Error incorrecto: \(error)")
        }
    }
    
    func test_execute_withFutureDate_throwsFutureDateError() async {
        // Given
        let existingEntry = DayEntry(text: "Original", createdAt: Date())
        mockRepository.entryToReturnByID = existingEntry
        
        let futureDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        
        // When/Then
        do {
            try await sut.execute(id: existingEntry.id, text: "Actualizado", date: futureDate)
            XCTFail("Debería haber lanzado error")
        } catch let error as DomainError {
            XCTAssertEqual(error, DomainError.futureDate)
        } catch {
            XCTFail("Error incorrecto: \(error)")
        }
    }
    
    // MARK: - Entry Not Found Cases
    
    func test_execute_withNonExistentEntry_throwsEntryNotFoundError() async {
        // Given
        let nonExistentID = UUID()
        mockRepository.entryToReturnByID = nil  // ← No existe
        
        // When/Then
        do {
            try await sut.execute(id: nonExistentID, text: "Actualizado")
            XCTFail("Debería haber lanzado error")
        } catch let error as DomainError {
            XCTAssertEqual(error, DomainError.entryNotFound)
        } catch {
            XCTFail("Error incorrecto: \(error)")
        }
    }
    
    func test_execute_whenEntryNotFound_doesNotCallUpdate() async {
        // Given
        let nonExistentID = UUID()
        mockRepository.entryToReturnByID = nil
        
        // When
        do {
            try await sut.execute(id: nonExistentID, text: "Actualizado")
        } catch {
            // Expected
        }
        
        // Then
        XCTAssertTrue(mockRepository.fetchByIDCalled)
        XCTAssertFalse(mockRepository.updateCalled)
    }
    
    // MARK: - Repository Error Cases
    
    func test_execute_whenRepositoryFails_propagatesError() async {
        // Given
        let existingEntry = DayEntry(text: "Original", createdAt: Date())
        mockRepository.entryToReturnByID = existingEntry
        
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = RepositoryError.mappingFailed
        
        // When/Then
        do {
            try await sut.execute(id: existingEntry.id, text: "Actualizado")
            XCTFail("Debería haber lanzado error")
        } catch let error as RepositoryError {
            XCTAssertEqual(error, RepositoryError.mappingFailed)
        } catch {
            XCTFail("Error incorrecto: \(error)")
        }
    }
    
    func test_execute_whenValidationFails_doesNotCallUpdate() async {
        // Given
        let existingEntry = DayEntry(text: "Original", createdAt: Date())
        mockRepository.entryToReturnByID = existingEntry
        
        // When
        do {
            try await sut.execute(id: existingEntry.id, text: "")  // Invalid
        } catch {
            // Expected
        }
        
        // Then
        XCTAssertTrue(mockRepository.fetchByIDCalled)
        XCTAssertFalse(mockRepository.updateCalled)
    }
    
    // MARK: - Boundary Cases
    
    func test_execute_withMaxLengthText_succeeds() async throws {
        // Given
        let existingEntry = DayEntry(text: "Original", createdAt: Date())
        mockRepository.entryToReturnByID = existingEntry
        
        let maxText = String(repeating: "a", count: 280)
        
        // When
        try await sut.execute(id: existingEntry.id, text: maxText)
        
        // Then
        XCTAssertTrue(mockRepository.updateCalled)
        XCTAssertEqual(mockRepository.lastUpdatedEntry?.text.count, 280)
    }
}
