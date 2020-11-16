//
//  ConveratinsListViewModel.swift
//  Chat
//
//  Created by Алексей Никитин on 09.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation
import CoreData

protocol ConversationsListModelProtocol: class {
    var delegate: ConversationsListModelDelegate? { get set }
    
    func fetch() -> NSFetchedResultsController<ChannelDB>
    func createChannel(with name: String)
    func deleteChannel(channel: Channel)
    func loadUser()
}

protocol ConversationsListModelDelegate: class {
    func channelDidCreate(channel: Channel)
    func showCreatingError(error: String)
    func showDeletingError(error: String)
    
    func userDidLoad(user: User)
}

class ConversationsListModel: ConversationsListModelProtocol {
    private let channelsService: ChannelsServiceProtocol
    private let userService: UserServiceProtocol
    weak var delegate: ConversationsListModelDelegate?
    
    init(channelsService: ChannelsServiceProtocol, userService: UserServiceProtocol) {
        self.channelsService = channelsService
        self.userService = userService
    }
    
    func fetch() -> NSFetchedResultsController<ChannelDB> {
        channelsService.resultController(for: nil)
    }
    
    func createChannel(with name: String) {
        channelsService.createChannel(with: name) { [weak delegate] (channel, error) in
            guard let delegate = delegate else { return }
            if let channel = channel {
                delegate.channelDidCreate(channel: channel)
            } else if let error = error {
                delegate.showCreatingError(error: error.localizedDescription)
            }
        }
    }
    
    func deleteChannel(channel: Channel) {
        channelsService.deleteChannel(with: channel.identifier) { [weak delegate] (error) in
            guard let delegate = delegate, let error = error else { return }
            delegate.showDeletingError(error: error.localizedDescription)           
        }
    }
    
    func loadUser() {
        userService.getUser { [weak delegate]  (user, _) in
            guard let delegate = delegate, let user = user else { return }
            delegate.userDidLoad(user: user)
        }
    }
}
