//
//  L10n.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 25/2/26.
//

import Foundation

/// Helper para localización de strings
/// Uso: L10n.entryInputTitle
enum L10n {
    
    // MARK: - Entry Input Card
    
    static let entryInputTitle = String(localized: "entry_input.title")
    static let entryInputPlaceholder = String(localized: "entry_input.placeholder")
    
    // MARK: - Date Picker Card
    
    static let datePickerTitle = String(localized: "date_picker.title")
    static let datePickerLabel = String(localized: "date_picker.label")
    
    // MARK: - Buttons
    
    static let buttonSave = String(localized: "button.save")
    static let buttonCancel = String(localized: "button.cancel")
    static let buttonDelete = String(localized: "button.delete")
    
    // MARK: - Home
    
    static let homeTitle = String(localized: "home.title")
    static let homeHeader = String(localized: "home.header")
    static let homeSubtitle = String(localized: "home.subtitle")
    
    // MARK: - Success
    
    static let successSaved = String(localized: "success.saved")
    
    // MARK: - Common
    
    static let commonOK = String(localized: "common.ok")
    static let commonError = String(localized: "common.error")
    static let commonDelete = String(localized: "common.delete")
    static let commonCancel = String(localized: "common.cancel")
    
    // MARK: - Errors with Parameters
    
    static func errorTextTooLong(maxLength: Int) -> String {
        String(localized: "error.text_too_long", defaultValue: "Text cannot exceed \(maxLength) characters")
            .replacingOccurrences(of: "%d", with: "\(maxLength)")
    }
    
    static func errorUnknown(message: String) -> String {
        String(localized: "error.unknown", defaultValue: "Unexpected error: \(message)")
            .replacingOccurrences(of: "%@", with: message)
    }
    
    // MARK: - Entry List

    static let entryListTitle = String(localized: "entry_list.title")
    static let entryListEmpty = String(localized: "entry_list.empty")
    static let entryListEmptySubtitle = String(localized: "entry_list.empty_subtitle")
    static let entryListDeleteConfirmation = String(localized: "entry_list.delete_confirmation")
}
