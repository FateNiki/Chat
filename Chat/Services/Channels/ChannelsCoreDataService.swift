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
    private(set) var channelsUpdate: () -> Void
    private var apiRepository: ChannelsApiRepository!
    
    init(channelsUpdate: @escaping () -> Void) {
        self.channelsUpdate = channelsUpdate
        self.apiRepository = ChannelsFirebaseDataSource { [weak self] channels in
            self?.channels = channels
            self?.channelsUpdate()
        }
    }
    
    public func loadChannels(_ completion: @escaping () -> Void) {
        apiRepository.loadChannels { [weak self] channels in
            self?.channels = channels
            completion()
        }
    }
    
    public func createChannel(with name: String, _ completion: @escaping (Channel?, Error?) -> Void) {
        apiRepository.createChannel(with: name, completion)
    }
}
