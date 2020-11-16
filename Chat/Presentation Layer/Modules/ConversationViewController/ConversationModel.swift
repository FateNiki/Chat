//
//  ConversationModel.swift
//  Chat
//
//  Created by Алексей Никитин on 09.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation
import CoreData

protocol ConversationModelProtocol: class {
    var delegate: ConversationModelDelegate? { get set }
    
    func fetch() -> NSFetchedResultsController<MessageDB>
    func createMessage(from user: User, with text: String)
}

protocol ConversationModelDelegate: class {
    func showMessageError(error: String)
}

class ConversationModel: ConversationModelProtocol {
    private var messagesService: MessagesServiceProtocol
    weak var delegate: ConversationModelDelegate?
    
    init(messagesService: MessagesServiceProtocol) {
        self.messagesService = messagesService
    }
    
    func fetch() -> NSFetchedResultsController<MessageDB> {
        return messagesService.resultController(for: nil)
    }
    
    func createMessage(from user: User, with text: String) {
        messagesService.createMessage(from: user, with: text) { [weak delegate] error in
            delegate?.showMessageError(error: error.localizedDescription)
        }
    }
}
