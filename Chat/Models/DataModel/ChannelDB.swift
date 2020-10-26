//
//  ChannelDB.swift
//  Chat
//
//  Created by Алексей Никитин on 23.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ChannelDB)
public class ChannelDB: NSManagedObject {
    @NSManaged public var identifier: String?
    @NSManaged public var lastActivity: Date?
    @NSManaged public var lastMessage: String?
    @NSManaged public var name: String?
    @NSManaged public var messages: NSSet?
    
    convenience init(identifier: String, name: String, lastMessage: String? = nil, lastActivity: Date? = nil, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.identifier = identifier
        self.name = name
        self.lastMessage = lastMessage
        self.lastActivity = lastActivity
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChannelDB> {
        return NSFetchRequest<ChannelDB>(entityName: "Channel")
    }
}

extension Channel {
    init?(from channelDB: ChannelDB) {
        guard let identifier = channelDB.identifier,
              let name = channelDB.name else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.lastMessage = channelDB.lastMessage
        self.lastActivity = channelDB.lastActivity
    }
}

// MARK: Generated accessors for messages
extension ChannelDB {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: MessageDB)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: MessageDB)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}
