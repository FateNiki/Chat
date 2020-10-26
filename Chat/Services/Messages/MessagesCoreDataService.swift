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
    private var apiRepository: MessagesApiRepository!
    
    init(for channel: Channel, messagesUpdate: @escaping () -> Void) {
        self.messagesUpdate = messagesUpdate
        self.apiRepository = MessagesFirebaseDataSource(for: channel) { [weak self] messages in
            self?.messages = messages
            self?.messagesUpdate()
        }
    }
    
    func loadMessages(_ completion: @escaping () -> Void) {
        apiRepository.loadMessages { [weak self] messages in
            self?.messages = messages
            completion()
        }
    }
    
    func createMessage(from sender: User, with text: String, _ errorCallback: @escaping (Error) -> Void) {
        apiRepository.createMessage(
            Message(content: text, senderId: sender.id, senderName: sender.fullName),
            errorCallback
        )
    }
}
