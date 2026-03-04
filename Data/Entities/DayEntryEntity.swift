//
//  DayEntryEntity.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 24/2/26.
//

import Foundation
import SwiftData

@Model
final class DayEntryEntity {
    
    //MARK: - Properties
    
    var id: UUID
    var text: String
    var createdAt: Date
    
    //MARK: - Init
    
    init(id: UUID, text: String, createdAt: Date) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}
