//
//  ChannelsCoreDataCacheService.swift
//  Chat
//
//  Created by Алексей Никитин on 26.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//
import Foundation
import CoreData

class ChannelsCoreDataCacheService: ChannelsCacheService {
    private let coreDataStack = CoreDataStack.shared
    
    func reloadChannels(_ channels: [Channel]) {
        coreDataStack.performSave { saveContext in
            let request: NSFetchRequest<ChannelDB> = ChannelDB.fetchRequest()
            guard let result = try? saveContext.fetch(request) else { return }
            result.forEach { saveContext.delete($0) }
            channels.forEach {
                _ = ChannelDB(identifier: $0.identifier,
                          name: $0.name,
                          lastMessage: $0.lastMessage,
                          lastActivity: $0.lastActivity,
                          in: saveContext)
            }
        }
        print()
    }
    
    func syncChanges(_ channelsChanges: [ChannelsChanges]) {
        coreDataStack.performSave { saveContext in
                        
            channelsChanges.forEach { diff in
                switch diff.event {
                case .create:
                    _ = ChannelDB(identifier: diff.channel.identifier,
                              name: diff.channel.name,
                              lastMessage: diff.channel.lastMessage,
                              lastActivity: diff.channel.lastActivity,
                              in: saveContext)
                case .update:
                    guard let channelDB = getChannel(with: diff.channel.identifier, for: saveContext) else { return }
                    channelDB.lastActivity = diff.channel.lastActivity
                    channelDB.lastMessage = diff.channel.lastMessage
                case .delete:
                    guard let channelDB = getChannel(with: diff.channel.identifier, for: saveContext) else { return }
                    saveContext.delete(channelDB)
                }
            }
        }
    }
    
    private func getChannel(with identifier: String, for context: NSManagedObjectContext) -> ChannelDB? {
        let request: NSFetchRequest<ChannelDB> = ChannelDB.fetchRequest()
        request.predicate = NSPredicate(format: "identifier = %@", identifier)
        guard let result = try? context.fetch(request), let channelDB = result.first else { return nil }
        return channelDB
    }
}
