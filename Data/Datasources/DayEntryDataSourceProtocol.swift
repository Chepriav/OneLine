//
//  DayEntryDataSource.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 24/2/26.
//

import Foundation

@MainActor
protocol DayEntryDataSourceProtocol {
    func insert(_ entity: DayEntryEntity) async throws
    func fetchAll() async throws -> [DayEntryEntity]
    func delete(_ entity: DayEntryEntity) async throws
    func fetchById(_ id: UUID) async throws -> DayEntryEntity?
    func save () async throws
}
