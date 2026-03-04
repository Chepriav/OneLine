//
//  DayEntryMapper.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 24/2/26.
//

import Foundation

enum DayEntryMapper {
    static func toEntity(_ domain: DayEntry) -> DayEntryEntity {
        DayEntryEntity(
            id: domain.id,
            text: domain.text,
            createdAt: domain.createdAt
        )
    }
    
    static func toDomain(_ entity: DayEntryEntity) -> DayEntry {
        DayEntry(
            id: entity.id,
            text: entity.text,
            createdAt: entity.createdAt
        )
    }
}
