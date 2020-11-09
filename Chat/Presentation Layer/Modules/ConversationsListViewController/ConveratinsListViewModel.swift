//
//  ConveratinsListViewModel.swift
//  Chat
//
//  Created by Алексей Никитин on 09.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation
import CoreData

protocol ConveratinsListViewModelProtocol: class {
    var delegate: ConveratinsListViewDelegate? { get set }
    
    func fetch() -> NSFetchedResultsController<ChannelDB>
    func createChannel(with name: String)
}

protocol ConveratinsListViewDelegate: class {
    func userDidReset(user: User)
    
    func channelWillCreate()
    func channelDidCreate(channel: Channel)
    func showCreatingError(error: String)
}
