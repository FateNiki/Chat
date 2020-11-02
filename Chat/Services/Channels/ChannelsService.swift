//
//  ChannelsService.swift
//  Chat
//
//  Created by Алексей Никитин on 25.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import CoreData

struct ChannelsChanges {
    enum Event {
        case create, update, delete
    }
    
    let event: Event
    let channel: Channel
}

protocol ChannelsService: class {
    func resultController(for predicate: NSPredicate?) -> NSFetchedResultsController<ChannelDB>
    func createChannel(with name: String, _ createCallback: @escaping(Channel?, Error?) -> Void)
}

protocol ChannelsApiRepository: class {
    var refreshCallback: ([ChannelsChanges]) -> Void { get }
    
    func loadAllChannels(_ completion: @escaping([Channel]) -> Void)
    func createChannel(with name: String, _ completion: @escaping(Channel?, Error?) -> Void)
}

protocol ChannelsCacheService: class {
    func reloadChannels(_ channels: [Channel])
    func syncChanges(_ channelsChanges: [ChannelsChanges])
}
