//
//  ChannelsCoreDataService.swift
//  Chat
//
//  Created by Алексей Никитин on 25.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

class ChannelsCoreDataService: ChannelsService {
    private(set) var channels: [Channel] = []
    private(set) var channelsDidUpdate: () -> Void
    
    private var cacheService: ChannelsCacheService!
    private var apiRepository: ChannelsApiRepository!
    
    init(channelsUpdate: @escaping () -> Void) {
        self.channelsDidUpdate = channelsUpdate
        
        self.cacheService = ChannelsCoreDataCacheService { [weak self] cacheChannels in
            guard let self = self else { return }
            self.channels = cacheChannels
            self.channelsDidUpdate()
        }
        
        self.apiRepository = ChannelsFirebaseDataSource { [weak self] channels in
            self?.cacheService.syncChannels(channels)
        }
    }
    
    private func getChannelsFromServer() {
        apiRepository.loadChannels { [weak self] channels in
            self?.cacheService.syncChannels(channels)
        }
    }
    
    public func getChannels(_ loadCallback: @escaping () -> Void) {
        cacheService.getChannels { [weak self] cacheChannels in
            guard let self = self else { return }
            self.channels = cacheChannels
            loadCallback()
            self.getChannelsFromServer()
        }
    }
    
    public func createChannel(with name: String, _ createCallback: @escaping (Channel?, Error?) -> Void) {
        let trimName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimName.isEmpty else {
            createCallback(nil, ErrorWithMessage(message: "Пустая строка"))
        }
        apiRepository.createChannel(with: trimName, createCallback)
    }
}
