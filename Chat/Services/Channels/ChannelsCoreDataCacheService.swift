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
        let context = coreDataStack.mainContext
        do {
            guard let result = try context.fetch(ChannelDB.fetchRequest()) as? [ChannelDB] else { return }
            completion(result.compactMap { Channel(from: $0)})
        } catch {
            completion([Channel]())
        }
    }
    
    func syncChannels(_ channels: [Channel]) {
        print("SYNC \(channels.count) channels")
        self.cacheDidChange(channels)
    }
}
