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
    
    var channelsCache: ChannelsCacheProtocol { get }
    func channelsRepo(refresh: @escaping ([ChannelsChanges]) -> Void) -> ChannelsRepositoryProtocol
    
    func messagesCache(for channel: Channel) -> MessagesCacheProtocol
    func messagesRepo(for channel: Channel, refresh: @escaping ([Message]) -> Void) -> MessagesRepositoryProtocol
    
    var themeStorage: ThemeStorageProtocol { get }
    
    var imagesListNetwork: PixabayListImages.PixabayRequestConfig { get }
    var imageNetwork: PixabayImage.PixabayRequestConfig { get }
}

class CoreAssembly: CoreAssemblyProtocol {
    // MARK: User
    lazy var userCGDStorage: UserStorageProtocol = GCDUserStorage.shared
    lazy var userOperationsStorage: UserStorageProtocol = OperationsUserStorage.shared
    
    // MARK: Channels
    lazy var channelsCache: ChannelsCacheProtocol = ChannelsCoreDataCache()
    func channelsRepo(refresh: @escaping ([ChannelsChanges]) -> Void) -> ChannelsRepositoryProtocol {
        ChannelsFirebaseRepository(refresh: refresh)
    }
    
    // MARK: Messages
    func messagesCache(for channel: Channel) -> MessagesCacheProtocol {
        MessagesCoreDataCache(for: channel)
    }    
    func messagesRepo(for channel: Channel, refresh: @escaping ([Message]) -> Void) -> MessagesRepositoryProtocol {
        MessagesFirebaseRepository(for: channel, refresh: refresh)
    }
    
    // MARK: Theme
    var themeStorage: ThemeStorageProtocol = ThemeFileStorage.shared
    
    // MARK: Images
    lazy var imagesListNetwork = PixabayListImages.PixabayRequestConfig(apiKey: "19155312-87cdfcaf15293d9b1c086517b")
    lazy var imageNetwork = PixabayImage.PixabayRequestConfig()
}
