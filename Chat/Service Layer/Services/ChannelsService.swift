//
//  ChannelsCoreDataService.swift
//  Chat
//
//  Created by Алексей Никитин on 25.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import CoreData

protocol ChannelsService: class {
    func resultController(for predicate: NSPredicate?) -> NSFetchedResultsController<ChannelDB>
    func createChannel(with name: String, _ createCallback: @escaping(Channel?, Error?) -> Void)
    func deleteChannel(with identifier: String, _ deleteCallback: @escaping(Error?) -> Void)
}

class ChannelsCoreDataService: ChannelsService {
    private var cache: ChannelsCache
    private var repository: ChannelsRepository
    
    init(cache: ChannelsCache, repo: ChannelsRepository) {
        self.cache = cache
        self.repository = repo        
        getChannelsFromServer()
    }
    
    private func getChannelsFromServer() {
        repository.loadAllChannels { [weak self] channels in
            self?.cache.reloadChannels(channels)
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
        repository.createChannel(with: trimName, createCallback)
    }
    
    public func deleteChannel(with identifier: String, _ deleteCallback: @escaping (Error?) -> Void) {
        repository.deleteChannel(with: identifier, deleteCallback)
    }
}
