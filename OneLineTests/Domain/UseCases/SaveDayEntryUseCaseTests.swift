//
//  SaveDayEntryUseCaseTests.swift
//  OneLineTests
//
//  Created by Carlos Hernandez Prieto on 26/2/26.
//

import XCTest
@testable import OneLine

@MainActor
final class SaveDayEntryUseCaseTests: XCTestCase {
    
    // MARK: - System Under Test
    
    var sut: SaveDayEntryUseCase!
    var mockRepository: MockDayEntryRepository!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockRepository = MockDayEntryRepository()
        sut = SaveDayEntryUseCase(repository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Success Cases
    
    func test_execute_withValidText_callsRepository() async throws {
        // Given
        let text = "Hoy fue genial"
        
        // When
        try await sut.execute(text: text)
        
        // Then
        XCTAssertTrue(mockRepository.saveCalled)
        XCTAssertEqual(mockRepository.saveCallCount, 1)
    }
    
    func test_execute_withValidText_savesCorrectEntry() async throws {
        // Given
        let text = "Hoy fue genial"
        let date = Date()
        
        // When
        try await sut.execute(text: text, date: date)
        
        // Then
        XCTAssertNotNil(mockRepository.lastSavedEntry)
        XCTAssertEqual(mockRepository.lastSavedEntry?.text, "Hoy fue genial")
        
        // Verificar fecha (con tolerancia de 1 segundo)
        if let savedDate = mockRepository.lastSavedEntry?.createdAt {
            XCTAssertEqual(savedDate.timeIntervalSince1970, date.timeIntervalSince1970, accuracy: 1.0)
        } else {
            XCTFail("La entrada guardada no tiene fecha")
        }
    }
    
    func test_execute_trimsWhitespace() async throws {
        // Given
        let text = "  Hoy fue genial  "
        
        // When
        try await sut.execute(text: text)
        
        // Then
        XCTAssertEqual(mockRepository.lastSavedEntry?.text, "Hoy fue genial")
    }
    
    func test_execute_generatesUniqueID() async throws {
        // Given
        let text1 = "Primera entrada"
        let text2 = "Segunda entrada"
        
        // When
        try await sut.execute(text: text1)
        let id1 = mockRepository.lastSavedEntry?.id
        
        try await sut.execute(text: text2)
        let id2 = mockRepository.lastSavedEntry?.id
        
        // Then
        XCTAssertNotNil(id1)
        XCTAssertNotNil(id2)
        XCTAssertNotEqual(id1, id2)
    }
    
    // MARK: - Validation Error Cases
    
    func test_execute_withEmptyText_throwsEmptyTextError() async {
        // Given
        let text = ""
        
        // When/Then
        do {
            try await sut.execute(text: text)
            XCTFail("Debería haber lanzado error")
        } catch let error as DomainError {
            XCTAssertEqual(error, DomainError.emptyText)
        } catch {
            XCTFail("Error incorrecto: \(error)")
        }
    }
    
    func test_execute_withWhitespaceOnly_throwsEmptyTextError() async {
        // Given
        let text = "   "
        
        // When/Then
        do {
            try await sut.execute(text: text)
            XCTFail("Debería haber lanzado error")
        } catch let error as DomainError {
            XCTAssertEqual(error, DomainError.emptyText)
        } catch {
            XCTFail("Error incorrecto: \(error)")
        }
    }
    
    func test_execute_withTextTooLong_throwsTextTooLongError() async {
        // Given
        let text = String(repeating: "a", count: 201)
        
        // When/Then
        do {
            try await sut.execute(text: text)
            XCTFail("Debería haber lanzado error")
        } catch let error as DomainError {
            if case .textTooLong(let maxLength) = error {
                XCTAssertEqual(maxLength, 200)
            } else {
                XCTFail("Error incorrecto: \(error)")
            }
        } catch {
            XCTFail("Error incorrecto: \(error)")
        }
    }
    
    func test_execute_withFutureDate_throwsFutureDateError() async {
        // Given
        let futureDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        let text = "Texto válido"
        
        // When/Then
        do {
            try await sut.execute(text: text, date: futureDate)
            XCTFail("Debería haber lanzado error")
        } catch let error as DomainError {
            XCTAssertEqual(error, DomainError.futureDate)
        } catch {
            XCTFail("Error incorrecto: \(error)")
        }
    }
    
    func test_execute_withMaxLengthText_succeeds() async throws {
        // Given
        let text = String(repeating: "a", count: 200)
        
        // When
        try await sut.execute(text: text)
        
        // Then
        XCTAssertTrue(mockRepository.saveCalled)
        XCTAssertEqual(mockRepository.lastSavedEntry?.text.count, 200)
    }
    
    // MARK: - Repository Error Cases
    
    func test_execute_whenRepositoryFails_propagatesError() async {
        // Given
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = RepositoryError.mappingFailed
        
        let text = "Texto válido"
        
        // When/Then
        do {
            try await sut.execute(text: text)
            XCTFail("Debería haber lanzado error")
        } catch let error as RepositoryError {
            XCTAssertEqual(error, RepositoryError.mappingFailed)
        } catch {
            XCTFail("Error incorrecto: \(error)")
        }
    }
    
    func test_execute_whenValidationFails_doesNotCallRepository() async {
        // Given
        let text = ""  // Invalid
        
        // When
        do {
            try await sut.execute(text: text)
        } catch {
            // Expected
        }
        
        // Then
        XCTAssertFalse(mockRepository.saveCalled)
    }
}
