//
//  ChannelsService.swift
//  Chat
//
//  Created by Алексей Никитин on 25.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

protocol ChannelsService: class {
    var channels: [Channel] { get }
    var channelsDidUpdate: () -> Void { get }
    
    func getChannels(_ loadCallback: @escaping() -> Void)
    
    func createChannel(with name: String, _ createCallback: @escaping(Channel?, Error?) -> Void)
}

protocol ChannelsApiRepository: class {
    func loadChannels(_ completion: @escaping([Channel]) -> Void)
    func createChannel(with name: String, _ completion: @escaping(Channel?, Error?) -> Void)
}

protocol ChannelsCacheService: class {
    func getChannels(_ completion: @escaping([Channel]) -> Void)
    
    func syncChannels(_ channels: [Channel])
}
