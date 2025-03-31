//
//  Item.swift
//  scrim
//
//  Created by Charles Choi on 3/31/25.
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
