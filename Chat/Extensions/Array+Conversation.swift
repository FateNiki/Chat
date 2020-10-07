//
//  Array+Conversation.swift
//  Chat
//
//  Created by Алексей Никитин on 28.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

extension Array where Element == Conversation {
    func withStatus(online: Bool) -> [Element] {
        self.filter {
            if online {
                return $0.isOnline
            } else {
                return !$0.isOnline && !$0.lastMessage.text.isEmpty
            }
        }.sorted {
            $0.lastMessage.date.timeIntervalSince1970 > $1.lastMessage.date.timeIntervalSince1970
        }
    }
}
