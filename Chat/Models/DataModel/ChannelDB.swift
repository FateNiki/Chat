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
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChannelDB> {
        return NSFetchRequest<ChannelDB>(entityName: "Channel")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var lastActivity: Date?
    @NSManaged public var lastMessage: String?
    @NSManaged public var name: String?
    @NSManaged public var messages: NSSet?

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
