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
    var messagesUpdate: () -> Void { get }
    
    func loadMessages(_ completion: @escaping() -> Void)
    
    func createMessage(from sender: User, with text: String, _ errorCallback: @escaping(Error) -> Void)
}
