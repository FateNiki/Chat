//
//  Message.swift
//  Chat
//
//  Created by Алексей Никитин on 26.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

struct Message {
    static let firebaseCollectionName = "messages"

    let content: String
    let created: Date
    let senderId: String
    let senderName: String
    
    init(content: String, created: Date = Date(), senderId: String, senderName: String) {
        self.content = content
        self.created = created
        self.senderId = senderId
        self.senderName = senderName
    }
}
