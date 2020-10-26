//
//  MessagesCoreDataCacheService.swift
//  Chat
//
//  Created by Алексей Никитин on 26.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import CoreData

class MessagesCoreDataCacheService: MessagesCacheService {
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
        print(context)
    }
    
    func getMessages(in channel: Channel, _ completion: @escaping ([Message]) -> Void) {
        print("RETURN cache messages")
        do {
            let request: NSFetchRequest<MessageDB> = MessageDB.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "created", ascending: false)]
            request.predicate = NSPredicate(format: "channel.identifier = %@", channel.identifier)
            let result = try coreDataStack.mainContext.fetch(request)
            completion(result.compactMap { Message(from: $0)})
        } catch {
            completion([])
        }
    }
    
    func syncMessages(in channel: Channel, _ newMessages: [Message]) {
        coreDataStack.performSave { saveContext in
            print("SYNC Messages")
            let request: NSFetchRequest<ChannelDB> = ChannelDB.fetchRequest()
            request.predicate = NSPredicate(format: "identifier = %@", channel.identifier)
            guard let result = try? coreDataStack.mainContext.fetch(request), let channelDB = result.first else { return }
            
            let newMessagesDB = newMessages.compactMap { MessageDB(message: $0, in: saveContext) }
            channelDB.addToMessages(NSSet(objects: newMessagesDB))
        }
    }
}
