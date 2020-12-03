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

struct ChannelsChanges {
    enum Event {
        case create, update, delete
    }
    
    let event: Event
    let channel: Channel
}

extension Channel: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
