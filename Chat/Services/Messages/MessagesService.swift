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
    var messagesDidUpdate: () -> Void { get }
    
    func getMessages(_ loadCallback: @escaping() -> Void)
    
    func createMessage(from sender: User, with text: String, _ errorCallback: @escaping(Error) -> Void)
}

protocol MessagesApiRepository {
    func loadMessages(_ completion: @escaping([Message]) -> Void)
    func createMessage(_ message: Message, _ errorCallback: @escaping(Error) -> Void)
}

protocol MessagesCacheService: class {
    func getMessages(in channel: Channel, _ completion: @escaping([Message]) -> Void)
    
    func syncMessages(in channel: Channel, _ messages: [Message])
}
