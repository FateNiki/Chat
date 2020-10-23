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
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageDB> {
        return NSFetchRequest<MessageDB>(entityName: "Message")
    }

    @NSManaged public var content: String?
    @NSManaged public var created: Date?
    @NSManaged public var senderId: String?
    @NSManaged public var senderName: String?
    @NSManaged public var channel: ChannelDB?

}
