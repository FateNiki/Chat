//
//  ChannelsCoreDataService.swift
//  Chat
//
//  Created by Алексей Никитин on 25.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import CoreData

class ChannelsCoreDataService: ChannelsService {
    
    static let shared = ChannelsCoreDataService()
    
    private var cacheService: ChannelsCacheService!
    private var apiRepository: ChannelsApiRepository!
    
    private init() {
        self.cacheService = ChannelsCoreDataCacheService()
        
        self.apiRepository = ChannelsFirebaseDataSource { [weak self] diff in
            self?.cacheService.syncChanges(diff)
        }
        
        getChannelsFromServer()
    }
    
    private func getChannelsFromServer() {
        apiRepository.loadAllChannels { [weak self] channels in
            self?.cacheService.reloadChannels(channels)
        }
    }
    
    public func resultController(for predicate: NSPredicate?) -> NSFetchedResultsController<ChannelDB> {
        let request: NSFetchRequest<ChannelDB> = ChannelDB.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = [ NSSortDescriptor(key: "lastActivity", ascending: false) ]
        return NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: CoreDataStack.shared.mainContext,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
    }
    
    public func createChannel(with name: String, _ createCallback: @escaping (Channel?, Error?) -> Void) {
        let trimName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimName.isEmpty else {
            createCallback(nil, ErrorWithMessage(message: "Пустая строка"))
            return
        }
        apiRepository.createChannel(with: trimName, createCallback)
    }
    
    public func deleteChannel(with identifier: String, _ deleteCallback: @escaping (Error?) -> Void) {
        apiRepository.deleteChannel(with: identifier, deleteCallback)
    }
}
