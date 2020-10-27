//
//  MessagesCoreDataCacheService.swift
//  Chat
//
//  Created by Алексей Никитин on 26.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import CoreData

class MessagesCoreDataCacheService: MessagesCacheService {
    private var cacheDidChange: ([Message]) -> Void
    private let coreDataStack = CoreDataStack.shared
    private let channel: Channel
    
    init(for channel: Channel, changeCallback: @escaping ([Message]) -> Void) {
        self.cacheDidChange = changeCallback
        self.channel = channel
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
        guard let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>,
              !insertedObjects.isEmpty else { return }
        let insertedMessages = insertedObjects.compactMap({ $0 as? MessageDB })
        guard !insertedMessages.isEmpty else { return }
        print("MESSAGES:\n\t insertedMessages", insertedMessages.count)
        getMessages(self.cacheDidChange)
    }
    
    private func getChannelDB(for context: NSManagedObjectContext) -> ChannelDB? {
        let request: NSFetchRequest<ChannelDB> = ChannelDB.fetchRequest()
        request.predicate = NSPredicate(format: "identifier = %@", channel.identifier)
        guard let result = try? context.fetch(request), let channelDB = result.first else { return nil }
        return channelDB
    }
    
    func getMessages(_ completion: @escaping ([Message]) -> Void) {
        do {
            let request: NSFetchRequest<MessageDB> = MessageDB.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "created", ascending: true)]
            guard let channelDB = getChannelDB(for: coreDataStack.mainContext) else {
                completion([])
                return
            }
            request.predicate = NSPredicate(format: "channel = %@", channelDB)
            let result = try coreDataStack.mainContext.fetch(request)
            completion(result.compactMap { Message(from: $0)})
        } catch {
            completion([])
        }
    }
    
    func syncMessages(newMessages: [Message]) {
        coreDataStack.performSave { saveContext in
            print("SYNC Messages")
            guard let channelDB = getChannelDB(for: saveContext) else { return }
            _ = newMessages.compactMap { MessageDB(message: $0, for: channelDB, in: saveContext) }            
        }
    }
}
