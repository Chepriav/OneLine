//
//  Untitled.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 23/2/26.
//

import Foundation
import SwiftData
import SwiftUI
import Observation

@MainActor
@Observable
final class HomeViewModel {

    //MARK: - Published State
    
    var newEntryText: String = ""
    var selectedDate: Date = Date()
    var isLoading: Bool = false
    var errorMessage: String?
    var showError: Bool = false
    var showSuccess: Bool = false
    
    private let saveUseCase: SaveDayEntryUseCase
    
    //MARK: - Init
    
    init(saveUseCase: SaveDayEntryUseCase) {
        self.saveUseCase = saveUseCase
    }
    
    func saveEntry() async {
        self.isLoading = true
        defer { self.isLoading = false }
        
        do {
            try await saveUseCase.execute(text: newEntryText, date: selectedDate)
            self.newEntryText = ""
            self.selectedDate = Date()
            self.showSuccess = true
            
            try? await Task.sleep(for: .seconds(2))
            showSuccess = false
        } catch let error as DomainError {
            errorMessage = error.localizedDescription
            showError = true
        } catch {
            errorMessage = "Error inesperado: \(error)."
            showError = true
        }
    }
    
    var canSave: Bool {
        !newEntryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }
}

