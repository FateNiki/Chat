//
//  ConfigurationModel.swift
//  Chat
//
//  Created by Алексей Никитин on 28.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

struct MessageCellModel {
    let text: String
    let income: Bool
}

struct ConversationCellModel: UserAvatarModelProtocol {
    let name: String
    let message: String
    let date: Date
    let isOnline: Bool
    let hasUnreadMessage: Bool
    
    // For Avatar
    let initials: String
    let avatar: Data?
}

struct UserAvatarModel: UserAvatarModelProtocol {
    let initials: String
    let avatar: Data?
}

protocol UserAvatarModelProtocol {
    var initials: String { get }
    var avatar: Data? { get }
}
