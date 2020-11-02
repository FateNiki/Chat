//
//  MessagesService.swift
//  Chat
//
//  Created by Алексей Никитин on 26.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import CoreData

protocol MessagesService: class {
    func resultController(for predicate: NSPredicate?) -> NSFetchedResultsController<MessageDB>
    func createMessage(from sender: User, with text: String, _ errorCallback: @escaping(Error) -> Void)
}

protocol MessagesApiRepository {
    func createMessage(from sender: User, with text: String, _ errorCallback: @escaping(Error) -> Void)
}

protocol MessagesCacheService: class {    
    func syncMessages(newMessages: [Message])
}
