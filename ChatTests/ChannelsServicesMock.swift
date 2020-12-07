//
//  ChannelsServicesMock.swift
//  ChatTests
//
//  Created by Алексей Никитин on 03.12.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//
@testable import Chat
import Foundation

class ChannelsRepoMock: ChannelsRepositoryProtocol {
    // Stub
    public var loadedChannelsStub: (() -> [Channel])?
    
    // Mock
    private(set) var countLoadAllChannelsCalls: Int = 0
    private(set) var loadedChannels: [Channel] = []
    
    /// Не нужен в данном тесте
    var refreshCallback: ([ChannelsChanges]) -> Void = { _ in }

    func loadAllChannels(_ completion: @escaping ([Channel]) -> Void) {
        countLoadAllChannelsCalls += 1
        loadedChannels = loadedChannelsStub?() ?? []
        completion(loadedChannels)
    }

    /// Не нужен в данном тесте
    func createChannel(with name: String, _ completion: @escaping (Channel?, Error?) -> Void) { }
    
    /// Не нужен в данном тесте
    func deleteChannel(with identifier: String, _ deleteCallback: @escaping (Error?) -> Void) {}
}

class ChannelsCacheMock: ChannelsCacheProtocol {
    private(set) var countReloadChannelsCalls: Int = 0
    private(set) var loadedChannels: [Channel] = []

    func reloadChannels(_ channels: [Channel]) {
        loadedChannels = channels
        countReloadChannelsCalls += 1
    }
    
    /// Не нужен в данном тесте
    func syncChanges(_ channelsChanges: [ChannelsChanges]) { }
}
