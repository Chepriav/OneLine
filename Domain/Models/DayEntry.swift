//
//  Entry.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 23/2/26.
//

import Foundation

public struct DayEntry: Equatable {
    public let id: UUID
    public let text: String
    public let createdAt: Date
    
    public init(
        id: UUID = UUID(),
        text: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}
