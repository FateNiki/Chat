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
        self.filter { $0.isOnline == online }
    }
}
