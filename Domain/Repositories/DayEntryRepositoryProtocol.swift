//
//  DayEntryRepositoryProtocol.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 24/2/26.
//

import Foundation

public protocol DayEntryRepositoryProtocol {
    func fetchAll() async throws -> [DayEntry]
    func save(_ dayEntry: DayEntry) async throws
    func delete(_ dayEntry: DayEntry) async throws
    func fetchByID(_ id: UUID) async throws -> DayEntry?
    func update(_ dayEntry: DayEntry) async throws
}
