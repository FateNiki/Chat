//
//  Channel.swift
//  Chat
//
//  Created by Алексей Никитин on 16.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

struct Channel {
    static let firebaseCollectionName = "channels"
    
    let identifier: String
    let name: String
    let lastMessage: String?
    let lastActivity: Date?
    
    init(id: String, name: String) {
        self.identifier = id
        self.name = name
        self.lastMessage = nil
        self.lastActivity = nil
    }
}
