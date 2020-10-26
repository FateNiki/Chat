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
    private var cacheDidChange: ([Channel]) -> Void
    private let coreDataStack = CoreDataStack()
    
    init(changeCallback: @escaping ([Channel]) -> Void) {
        self.cacheDidChange = changeCallback
    }
    
    func getChannels(_ completion: @escaping ([Channel]) -> Void) {
        print("RETURN cache channels")
        do {
            guard let result = try coreDataStack.mainContext.fetch(ChannelDB.fetchRequest()) as? [ChannelDB] else { return }
            completion(result.compactMap { Channel(from: $0)})
        } catch {
            completion([Channel]())
        }
    }
    
    func syncChannels(_ channels: [Channel]) {
        coreDataStack.performSave { saveContext in
            let result = channels.compactMap { channel in
                ChannelDB(identifier: channel.identifier,
                          name: channel.name,
                          lastMessage: channel.lastMessage,
                          lastActivity: channel.lastActivity,
                          in: saveContext)
            }
            print("SYNC \(result.count) channels")
            self.cacheDidChange(channels)
        }
    }
}
