//
//  DomainError.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 24/2/26.
//

import Foundation

enum DomainError: Error, LocalizedError, Equatable {
    
    case emptyText
    case textTooLong(maxLength: Int)
    case futureDate
    case entryNotFound
    
    var errorDescription: String? {
        switch self {
        case .emptyText:
            return String(localized: "error.empty_text")
            
        case .textTooLong(let maxLength):
            return L10n.errorTextTooLong(maxLength: maxLength)
            
        case .futureDate:
            return String(localized: "error.future_date")
            
        case .entryNotFound:
            return String(localized: "error.entry_not_found")
        }
    }
}
