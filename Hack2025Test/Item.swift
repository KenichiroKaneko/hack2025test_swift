//
//  Item.swift
//  Hack2025Test
//
//  Created by 健一郎金子 on 2025/06/18.
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
