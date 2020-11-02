//
//  MessagesCoreDataCacheService.swift
//  Chat
//
//  Created by Алексей Никитин on 26.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import CoreData

class MessagesCoreDataCacheService: MessagesCacheService {
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
        
    func syncMessages(newMessages: [Message]) {
        coreDataStack.performSave { saveContext in
            guard let channelDB = getChannelDB(for: saveContext) else { return }
            _ = newMessages.compactMap { MessageDB(message: $0, for: channelDB, in: saveContext) }            
        }
    }
}
