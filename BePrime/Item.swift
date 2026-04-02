//
//  Item.swift
//  BePrime
//
//  Created by Nishant Taneja on 02/04/26.
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
