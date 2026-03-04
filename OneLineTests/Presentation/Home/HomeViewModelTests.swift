//
//  HomeViewModelTests.swift
//  OneLineTests
//
//  Created by Carlos Hernandez Prieto on 26/2/26.
//

import Foundation
import XCTest

@testable import OneLine

@MainActor
final class HomeViewModelTests: XCTestCase {
    
    //MARK: - System under test
    
    var sut: HomeViewModel!
    var mockRepository: MockDayEntryRepository!
    var saveUseCase: SaveDayEntryUseCase!
        
    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        
        mockRepository = MockDayEntryRepository()
        saveUseCase = SaveDayEntryUseCase(repository: mockRepository)
        sut = .init(saveUseCase: saveUseCase)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        saveUseCase = nil
        super.tearDown()
    }
    
    
    
    
    
}
