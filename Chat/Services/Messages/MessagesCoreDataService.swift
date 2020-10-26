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
    private(set) var messagesDidAdd: () -> Void
    
    private var cacheService: MessagesCacheService!
    private var apiRepository: MessagesApiRepository!
    
    init(for channel: Channel, messagesDidAdd: @escaping () -> Void) {
        self.messagesDidAdd = messagesDidAdd
        
        self.cacheService = MessagesCoreDataCacheService(for: channel) { [weak self] cacheMessages in
            guard let self = self else { return }
            self.messages = cacheMessages
            self.messagesDidAdd()
        }
        
        self.apiRepository = MessagesFirebaseDataSource(for: channel) { [weak self] newMessages in
            self?.cacheService.syncMessages(newMessages: newMessages)
        }
    }
    
    func getMessages(_ completion: @escaping () -> Void) {
        cacheService.getMessages { [weak self] cacheMessages in
            guard let self = self else { return }
            self.messages = cacheMessages
            completion()
            self.apiRepository.loadMessages(after: self.messages.last)
        }
    }
    
    func createMessage(from sender: User, with text: String, _ errorCallback: @escaping (Error) -> Void) {
        apiRepository.createMessage(
            Message(content: text, senderId: sender.id, senderName: sender.fullName),
            errorCallback
        )
    }
}
