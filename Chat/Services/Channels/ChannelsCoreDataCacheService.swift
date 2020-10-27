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
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, HH:mm"
        return formatter
    }()
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
    
    private func printChannelLog(channelDB: ChannelDB) {
        print("\t\t \(channelDB.name ?? "") | количество сообщений: \(channelDB.messages?.count ?? 0)")
        print("\t\t\t – \(channelDB.lastMessage ?? "")")
        guard let lastActivity = channelDB.lastActivity else { return }
        print("\t\t\t – \(Self.dateFormatter.string(from: lastActivity))")
    }
    
    @objc private func observeNotificatino(_ notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext, context.parent == nil else { return }
        
        if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>, !insertedObjects.isEmpty {
            let insertedChannels = insertedObjects.compactMap { $0 as? ChannelDB }
            guard !insertedChannels.isEmpty else { return }
            print("CHANNELS:\n\t insertedChannels", insertedChannels.count)
            insertedChannels.forEach(printChannelLog)
            getChannels(self.cacheDidChange)
            return
        }
        if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, !updatedObjects.isEmpty {
            let updatedChannels = updatedObjects.compactMap { $0 as? ChannelDB }
            guard !updatedChannels.isEmpty else { return }
            print("CHANNELS:\n\t updatedChannels", updatedChannels.count)
            getChannels(self.cacheDidChange)
            return
        }
        if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, !deletedObjects.isEmpty {
            let deletedChannels = deletedObjects.compactMap { $0 as? ChannelDB }
            guard !deletedChannels.isEmpty else { return }
            print("CHANNELS:\n\t deletedChannels", deletedChannels.count)
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
