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
    var channelsUpdate: () -> Void { get }
    
    func loadChannels(_ completion: @escaping() -> Void)
    
    func createChannel(with name: String, _ completion: @escaping(Channel?, Error?) -> Void)
}

protocol ChannelsApiRepository {
    func loadChannels(_ completion: @escaping([Channel]) -> Void)
    func createChannel(with name: String, _ completion: @escaping(Channel?, Error?) -> Void)
}
