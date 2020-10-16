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
    let date: Date
    let income: Bool
}

extension Message {
    func cellModel(for user: User) -> MessageCellModel {
        return MessageCellModel(text: content, date: created, income: senderId != user.id)
    }
}

struct ChannelCellModel: UserAvatarModelProtocol {
    let name: String
    let message: String?
    let date: Date?
    
    // For Avatar
    let initials: String
    let avatar: Data?
}

extension Channel {
    private var initials: String {
        let nameArray = name.split(separator: "0", maxSplits: 1).filter { !$0.isEmpty }
        guard nameArray.count > 0 else { return "?" }
        
        return String(nameArray.map { $0[$0.startIndex] })
    }
    
    func cellModel() -> ChannelCellModel {
        return ChannelCellModel(
            name: name,
            message: lastMessage,
            date: lastActivity,
            initials: initials,
            avatar: nil
        )
    }
}

struct UserAvatarModel: UserAvatarModelProtocol {
    let initials: String
    let avatar: Data?
}

protocol UserAvatarModelProtocol {
    var initials: String { get }
    var avatar: Data? { get }
}

extension User {
    func avatarModel(with imageData: Data? = nil) -> UserAvatarModel {
        return UserAvatarModel(initials: initials, avatar: imageData ?? avatar)
    }
}
