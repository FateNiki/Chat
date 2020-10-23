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
    var description: String
    var avatar: Data?
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    var initials: String {
        let nameArray: [String] = [firstName, lastName].filter { !$0.isEmpty }
        guard nameArray.count > 0 else { return "?" }
        
        return String(nameArray.map { $0[$0.startIndex] })
    }
    
    init(id: String, firstName: String = "", lastName: String = "", description: String = "", avatar: Data? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.description = description
        self.avatar = avatar        
    }
}
