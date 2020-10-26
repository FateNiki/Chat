//
//  ChannelsCoreDataCacheService.swift
//  Chat
//
//  Created by Алексей Никитин on 26.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

class ChannelsCoreDataCacheService: ChannelsCacheService {
    func getChannels(_ completion: @escaping ([Channel]) -> Void) {
        completion([Channel]())
    }
    
    func syncChannels(_ channels: [Channel]) {
        print("sync \(channels.count) channels")
        
    }
}
