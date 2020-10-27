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
    private let coreDataStack = CoreDataStack.shared
    
    init(changeCallback: @escaping ([Channel]) -> Void) {
        self.cacheDidChange = changeCallback
        initObserver()
    }
    
    private func initObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(observeNotificatino(_:)),
            name: .NSManagedObjectContextDidSave,
            object: nil)
    }
    
    @objc private func observeNotificatino(_ notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext, context.parent == nil else { return }
        
        print("NOTIFY Channels")
        if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>, !insertedObjects.isEmpty {
            print("\tinsertedObjects", insertedObjects.count)
            getChannels(self.cacheDidChange)
            return
        }
        if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, !updatedObjects.isEmpty {
            print("\tupdatedObjects", updatedObjects.count)
            getChannels(self.cacheDidChange)
            return
        }
        if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, !deletedObjects.isEmpty {
            print("\tdeletedObjects", deletedObjects.count)
            getChannels(self.cacheDidChange)
            return
        }
    }
    
    func getChannels(_ completion: @escaping ([Channel]) -> Void) {
        do {
            let request: NSFetchRequest<ChannelDB> = ChannelDB.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "lastActivity", ascending: false)]
            let result = try coreDataStack.mainContext.fetch(request)
            completion(result.compactMap { Channel(from: $0)})
        } catch {
            completion([Channel]())
        }
    }
    
    func syncChannels(_ channels: [Channel]) {
        coreDataStack.performSave { saveContext in
            print("SYNC Channels")
            channels.forEach { channel in
                _ = ChannelDB(identifier: channel.identifier,
                          name: channel.name,
                          lastMessage: channel.lastMessage,
                          lastActivity: channel.lastActivity,
                          in: saveContext)
            }
        }
    }
}
