//
//  UserAvatarViewDelegate.swift
//  Chat
//
//  Created by Алексей Никитин on 29.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

protocol UserAvatarViewDelegate: class {
    func userAvatarDidTap()
}

protocol UserViewDelegate: class {
    func userDidChange(newUser: User)
}
