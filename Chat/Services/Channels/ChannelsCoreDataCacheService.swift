//
//  ChannelsCoreDataCacheService.swift
//  Chat
//
//  Created by Алексей Никитин on 26.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

class ChannelsCoreDataCacheService: ChannelsCacheService {
    private var cacheDidChange: ([Channel]) -> Void
    
    init(changeCallback: @escaping ([Channel]) -> Void) {
        self.cacheDidChange = changeCallback
    }
    
    func getChannels(_ completion: @escaping ([Channel]) -> Void) {
        completion([Channel]())
    }
    
    func syncChannels(_ channels: [Channel]) {
        print("sync \(channels.count) channels")
        self.cacheDidChange(channels)
    }
}
