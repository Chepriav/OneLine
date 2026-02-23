//
//  Item.swift
//  Daily micro-Journal
//
//  Created by Carlos Hernandez Prieto on 23/2/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
