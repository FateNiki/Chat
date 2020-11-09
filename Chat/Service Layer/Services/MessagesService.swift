//
//  MessagesCoreDataService.swift
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

class MessagesCoreDataService: MessagesService {
    private let cache: MessagesCache
    private let repository: MessagesRepository!
    private let channel: Channel
    
    init(for channel: Channel, cache: MessagesCache, repository: MessagesRepository) {
        self.channel = channel
        self.cache = cache
        self.repository = repository
        
        self.repository.loadAllMessages { [weak self] allMessages in
            self?.cache.reloadMessages(allMessages)
        }
    }
    
    public func createMessage(from sender: User, with text: String, _ errorCallback: @escaping (Error) -> Void) {
        let trimText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimText.isEmpty else {
            errorCallback(ErrorWithMessage(message: "Пустая строка"))
            return
        }
        
        repository.createMessage(from: sender, with: text, errorCallback)
    }
    
    public func resultController(for predicate: NSPredicate?) -> NSFetchedResultsController<MessageDB> {
        let request: NSFetchRequest<MessageDB> = MessageDB.fetchRequest()
        let channelPredicate = NSPredicate(format: "channel.identifier = %@", channel.identifier)
        if let externalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [channelPredicate, externalPredicate])
        } else {
            request.predicate = channelPredicate
        }
        request.sortDescriptors = [ NSSortDescriptor(key: "created", ascending: true) ]
        request.fetchBatchSize = 30
        return NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: CoreDataStack.shared.mainContext,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
    }
}
