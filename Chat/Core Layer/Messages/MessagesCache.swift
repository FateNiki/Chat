//
//  MessagesCoreDataCacheService.swift
//  Chat
//
//  Created by Алексей Никитин on 26.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import CoreData

protocol MessagesCacheProtocol: class {
    func reloadMessages(_ messages: [Message])
    func syncChanges(newMessages: [Message])
}

class MessagesCoreDataCache: MessagesCacheProtocol {
    private let coreDataStack = CoreDataStack.shared
    private let channel: Channel
    
    init(for channel: Channel) {
        self.channel = channel
    }
    
    private func getChannelDB(for context: NSManagedObjectContext) -> ChannelDB? {
        let request: NSFetchRequest<ChannelDB> = ChannelDB.fetchRequest()
        request.predicate = NSPredicate(format: "identifier = %@", channel.identifier)
        guard let result = try? context.fetch(request), let channelDB = result.first else { return nil }
        return channelDB
    }
        
    func syncChanges(newMessages: [Message]) {
        coreDataStack.performSave { saveContext in
            guard let channelDB = getChannelDB(for: saveContext) else { return }
            _ = newMessages.compactMap { MessageDB(message: $0, for: channelDB, in: saveContext) }            
        }
    }
    
    func reloadMessages(_ loadedMessages: [Message]) {
        coreDataStack.performSave { saveContext in
            let request: NSFetchRequest<MessageDB> = MessageDB.fetchRequest()
            request.predicate = NSPredicate(format: "channel.identifier = %@", channel.identifier)
            
            guard let cachedMessages = try? saveContext.fetch(request),
                  let channelDB = getChannelDB(for: saveContext) else { return }
            
            loadedMessages.forEach { message in
                if !cachedMessages.contains(where: { $0.identifier == message.identifier }) {
                    _ = MessageDB(message: message, for: channelDB, in: saveContext)
                }
            }
        }
        
    }
}
