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
    
    func getChannelsService() -> ChannelsServiceProtocol
    
    func getMessagesService(for channel: Channel) -> MessagesServiceProtocol
    
    func getThemeService() -> ThemeServiceProtocol
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
    
    func getChannelsService() -> ChannelsServiceProtocol {
        let cache = coreAssembly.channelsCache
        let repo = coreAssembly.channelsRepo(refresh: { [weak cache] diff in
            cache?.syncChanges(diff)
        })
        return ChannelsService(cache: cache, repo: repo)
    }
    
    func getMessagesService(for channel: Channel) -> MessagesServiceProtocol {
        let cache = coreAssembly.messagesCache(for: channel)
        let repo = coreAssembly.messagesRepo(for: channel, refresh: { [weak cache] newMessages in
            cache?.syncChanges(newMessages: newMessages)
        })
        return MessagesService(for: channel, cache: cache, repository: repo)
    }
    
    func getThemeService() -> ThemeServiceProtocol {
        return ThemeService(storage: coreAssembly.themeStorage)
    }
}
