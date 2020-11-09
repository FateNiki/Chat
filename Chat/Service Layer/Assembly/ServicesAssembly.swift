//
//  ServicesAssembly.swift
//  Chat
//
//  Created by Алексей Никитин on 09.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

enum AllowedUserStorages {
    case gcd, operations
}

protocol ServicesAssemblyProtocol {
    func getUserService(for userStorage: AllowedUserStorages) -> UserServiceProtocol
    
    func getChannelsService() -> ChannelsService
    
    func getMessagesService(for channel: Channel) -> MessagesService
}

class ServicesAssembly: ServicesAssemblyProtocol {
    private let coreAssembly: CoreAssemblyProtocol
    
    init(coreAssembly: CoreAssemblyProtocol) {
        self.coreAssembly = coreAssembly
    }
    
    func getUserService(for userStorage: AllowedUserStorages) -> UserServiceProtocol {
        switch userStorage {
        case .gcd:
            return UserService(storage: coreAssembly.userCGDStorage)
        case .operations:
            return UserService(storage: coreAssembly.userOperationsStorage)
        }
    }
    
    func getChannelsService() -> ChannelsService {
        let cache = coreAssembly.channelsCache
        let repo = coreAssembly.channelsRepo(refresh: { [weak cache] diff in
            cache?.syncChanges(diff)
        })
        return ChannelsCoreDataService(cache: cache, repo: repo)
    }
    
    func getMessagesService(for channel: Channel) -> MessagesService {
        let cache = coreAssembly.messagesCache(for: channel)
        let repo = coreAssembly.messagesRepo(for: channel, refresh: { [weak cache] newMessages in
            cache?.syncChanges(newMessages: newMessages)
        })
        return MessagesCoreDataService(for: channel, cache: cache, repository: repo)
    }
}
