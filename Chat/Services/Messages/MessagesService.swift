//
//  MessagesService.swift
//  Chat
//
//  Created by Алексей Никитин on 26.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

protocol MessagesService: class {
    var messages: [Message] { get }
    var messagesDidAdd: () -> Void { get }
    
    func getMessages(_ loadCallback: @escaping() -> Void)
    
    func createMessage(from sender: User, with text: String, _ errorCallback: @escaping(Error) -> Void)
}

protocol MessagesApiRepository {
    func loadMessages(after message: Message?)
    func createMessage(_ message: Message, _ errorCallback: @escaping(Error) -> Void)
}

protocol MessagesCacheService: class {
    func getMessages(_ completion: @escaping([Message]) -> Void)
    
    func syncMessages(newMessages: [Message])
}
