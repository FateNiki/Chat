//
//  MessagesCoreDataService.swift
//  Chat
//
//  Created by Алексей Никитин on 26.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import CoreData

class MessagesCoreDataService: MessagesService {
    private var cacheService: MessagesCacheService
    private var apiRepository: MessagesApiRepository!
    private let channel: Channel
    
    init(for channel: Channel) {
        self.channel = channel
        self.cacheService = MessagesCoreDataCacheService(for: channel)
        self.apiRepository = MessagesFirebaseDataSource(for: channel) { [weak self] newMessages in
            self?.cacheService.syncMessages(newMessages: newMessages)
        }
    }
    
    public func createMessage(from sender: User, with text: String, _ errorCallback: @escaping (Error) -> Void) {
        let trimText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimText.isEmpty else {
            errorCallback(ErrorWithMessage(message: "Пустая строка"))
            return
        }
        
        apiRepository.createMessage(from: sender, with: text, errorCallback)
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
        return NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: CoreDataStack.shared.mainContext,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
    }
}
