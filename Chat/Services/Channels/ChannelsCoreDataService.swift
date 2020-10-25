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
    private lazy var firebaseDataSource: ChannelsFirebaseDataSource = {
        ChannelsFirebaseDataSource(refresh: { (channels) in
            self.channels = channels
            self.channelsUpdate()
        })
    }()
    
    init(channelsUpdate: @escaping () -> Void) {
        self.channelsUpdate = channelsUpdate
    }
    
    public func loadChannels(_ completion: @escaping () -> Void) {
        firebaseDataSource.loadChannels { (channels) in
            self.channels = channels
            completion()
        }
    }
    
    public func createChannel(with name: String, _ completion: @escaping (Channel?, Error?) -> Void) {
//        let newChannelRef = channelsRef.document()
//        let newChannel = Channel(id: newChannelRef.documentID, name: name)
//        newChannelRef.setData(newChannel.data) { [weak self] (error) in
//
//        }
        completion(nil, TestError(message: "TEST CREATE CHANNEL"))
    }
}
