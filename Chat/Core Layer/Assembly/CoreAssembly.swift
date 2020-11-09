//
//  CoreAssembly.swift
//  Chat
//
//  Created by Алексей Никитин on 09.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

protocol CoreAssemblyProtocol {    
    var userCGDStorage: UserStorageProtocol { get }
    var userOperationsStorage: UserStorageProtocol { get }
    
    var channelsCache: ChannelsCache { get }
    func channelsRepo(refresh: @escaping ([ChannelsChanges]) -> Void) -> ChannelsRepository
    
    func messagesCache(for channel: Channel) -> MessagesCache
    func messagesRepo(for channel: Channel, refresh: @escaping ([Message]) -> Void) -> MessagesRepository
}

class CoreAssembly: CoreAssemblyProtocol {
    // MARK: User
    lazy var userCGDStorage: UserStorageProtocol = GCDUserStorage.shared
    lazy var userOperationsStorage: UserStorageProtocol = OperationsUserStorage.shared
    
    // MARK: Channels
    lazy var channelsCache: ChannelsCache = ChannelsCoreDataCache()
    func channelsRepo(refresh: @escaping ([ChannelsChanges]) -> Void) -> ChannelsRepository {
        ChannelsFirebaseDataSource(refresh: refresh)
    }
    
    // MARK: Messages
    func messagesCache(for channel: Channel) -> MessagesCache {
        MessagesCoreDataCache(for: channel)
    }    
    func messagesRepo(for channel: Channel, refresh: @escaping ([Message]) -> Void) -> MessagesRepository {
        MessagesFirebaseDataSource(for: channel, refresh: refresh)
    }
}
