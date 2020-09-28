//
//  ConversationsMock.swift
//  Chat
//
//  Created by Алексей Никитин on 26.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

let conversationsMock: [Conversation] = mockUsers.map {
    Conversation(
        user: $0,
        lastMessage: Message(text: randomMessage(), date: randomDate(), direction: . isRead: false),
        isOnline: Bool.random()
    )
}
