//
//  Item.swift
//  learner
//
//  Created by Mr. Samat on 10.12.2025.
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
