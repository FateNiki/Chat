//
//  MessagesCoreDataService.swift
//  Chat
//
//  Created by Алексей Никитин on 26.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

class MessagesCoreDataService: MessagesService {
    private(set) var messages: [Message] = []
    private(set) var messagesUpdate: () -> Void
    private var firebaseDataSource: MessagesFirebaseDataSource!
    
    init(for channel: Channel, messagesUpdate: @escaping () -> Void) {
        self.messagesUpdate = messagesUpdate
        self.firebaseDataSource = MessagesFirebaseDataSource(for: channel) { [weak self] messages in
            self?.messages = messages
            self?.messagesUpdate()
        }
    }
    
    func loadMessages(_ completion: @escaping () -> Void) {
        firebaseDataSource.loadChannels { [weak self] messages in
            self?.messages = messages
            completion()
        }
    }
    
    func createMessage(from sender: User, with text: String, _ errorCallback: @escaping (Error) -> Void) {
        firebaseDataSource.createMessage(Message(content: text, senderId: sender.id, senderName: sender.fullName), errorCallback)
    }
    
}
