//
//  ChannelsCoreDataCacheService.swift
//  Chat
//
//  Created by Алексей Никитин on 26.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//
import Foundation
import CoreData

protocol ChannelsCacheProtocol: class {
    func reloadChannels(_ channels: [Channel])
    func syncChanges(_ channelsChanges: [ChannelsChanges])
}

class ChannelsCoreDataCache: ChannelsCacheProtocol {
    private let coreDataStack = CoreDataStack.shared
    
    func reloadChannels(_ channels: [Channel]) {
        coreDataStack.performSave { saveContext in
            let request: NSFetchRequest<ChannelDB> = ChannelDB.fetchRequest()
            guard let cachedChannels = try? saveContext.fetch(request) else { return }
            var updatedChannels = [(ChannelDB, Channel)]()
            var deletedChannels = [ChannelDB]()
            var newChannels = channels
            
            cachedChannels.forEach { channelDB in
                guard let channelIndex = newChannels.firstIndex(where: { $0.identifier == channelDB.identifier }) else {
                    deletedChannels.append(channelDB)
                    return
                }
                let updatedChannel = newChannels.remove(at: channelIndex)
                updatedChannels.append((channelDB, updatedChannel))
            }
            
            newChannels.forEach {
                _ = ChannelDB(identifier: $0.identifier,
                          name: $0.name,
                          lastMessage: $0.lastMessage,
                          lastActivity: $0.lastActivity,
                          in: saveContext)
            }
            deletedChannels.forEach { saveContext.delete($0) }
            updatedChannels.forEach {
                $0.lastActivity = $1.lastActivity
                $0.lastMessage = $1.lastMessage
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
