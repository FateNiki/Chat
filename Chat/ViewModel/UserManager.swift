//
//  UserManager.swift
//  Chat
//
//  Created by Алексей Никитин on 10.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

struct UserData {
    let fullName: String
    let description: String
    let avatar: Data?
}

protocol UserManager: DataManager where ManagerData == UserData, ManagerResult == User {
}

class GCDUserManager: UserManager {
    static let shared = GCDUserManager()
    
    func saveToFile(data: UserData, completion: @escaping (User) -> Void) {
        UserMock.currentUser.avatar = data.avatar
        UserMock.currentUser.description = data.description
        let names = data.fullName.split(separator: Character(" "), maxSplits: 2, omittingEmptySubsequences: true)
        UserMock.currentUser.firstName = names.count > 0 ? String(names[0]) : ""
        UserMock.currentUser.lastName = names.count > 1 ? String(names[1]) : ""

        completion(UserMock.currentUser)
    }
    
    func loadFromFile(completion: @escaping (User) -> Void) {
        completion(UserMock.currentUser)
    }
    
    private init() { }
}

class OperationsUserManager: UserManager {
    static let shared = OperationsUserManager()
    
    func saveToFile(data: UserData, completion: @escaping (User) -> Void) {
        UserMock.currentUser.avatar = data.avatar
        UserMock.currentUser.description = data.description
        let names = data.fullName.split(separator: Character(" "), maxSplits: 2, omittingEmptySubsequences: true)
        UserMock.currentUser.firstName = names.count > 0 ? String(names[0]) : ""
        UserMock.currentUser.lastName = names.count > 1 ? String(names[1]) : ""
        
        completion(UserMock.currentUser)
    }
    
    func loadFromFile(completion: @escaping (User) -> Void) {
        completion(UserMock.currentUser)
    }
    
    private init() { }
}


