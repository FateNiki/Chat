//
//  User.swift
//  Chat
//
//  Created by Алексей Никитин on 20.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    
    var firstName: String
    var lastName: String
    var description: String?
    var avatar: Data?
}
