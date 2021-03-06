//
//  MessageDB+CoreDataClass.swift
//  Chat
//
//  Created by Алексей Никитин on 23.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//
//

import Foundation
import CoreData

@objc(MessageDB)
public class MessageDB: NSManagedObject {
    @NSManaged public var identifier: String?
    @NSManaged public var content: String?
    @NSManaged public var created: Date?
    @NSManaged public var senderId: String?
    @NSManaged public var senderName: String?
    @NSManaged public var channel: ChannelDB?
    
    convenience init(message: Message, for channel: ChannelDB? = nil, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.identifier = message.identifier
        self.content = message.content
        self.created = message.created
        self.senderId = message.senderId
        self.senderName = message.senderName
        self.channel = channel
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageDB> {
        return NSFetchRequest<MessageDB>(entityName: "Message")
    }
}

extension Message {
    init?(from messageDB: MessageDB) {
        guard let identifier = messageDB.identifier,
              let content = messageDB.content,
              let senderId = messageDB.senderId,
              let senderName = messageDB.senderName,
              let created = messageDB.created
              else { return nil }
        self.identifier = identifier
        self.content = content
        self.created = created
        self.senderId = senderId
        self.senderName = senderName
    }
}
