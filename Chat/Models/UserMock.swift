//
//  UserMock.swift
//  Chat
//
//  Created by Алексей Никитин on 20.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

private let description = "Frontend developer, iOS Developer, Izhevsk, Russia"
private let avatar = UIImage(named: "mockAvatar")

let mockUser = User(id: UUID(), firstName: "Aleksey", lastName: "Nikitin", description: description, avatar: avatar?.pngData())
