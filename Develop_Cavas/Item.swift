//
//  Item.swift
//  Develop_Cavas
//
//  Created by 하늘 on 9/23/24.
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
