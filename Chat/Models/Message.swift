//
//  Message.swift
//  Chat
//
//  Created by Алексей Никитин on 26.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

struct Message {
    enum Direction {
        case income
        case outcome
    }
    
    let text: String
    let date: Date
    let direction: Direction
    var isRead: Bool
}
