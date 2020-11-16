//
//  UserService.swift
//  Chat
//
//  Created by Алексей Никитин on 09.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

protocol UserServiceProtocol {
    func getUser(_ completion: @escaping (User?, UserStorageError?) -> Void)
    func saveUser(data: UserStorageData, completion: @escaping (User?, UserStorageError?) -> Void)
}

class UserService: UserServiceProtocol {
    private var storage: UserStorageProtocol
    
    init(storage: UserStorageProtocol) {
        self.storage = storage
    }
    
    func getUser(_ completion: @escaping (User?, UserStorageError?) -> Void) {
        storage.loadFromFile(completion: completion)
    }
    
    func saveUser(data: UserStorageData, completion: @escaping (User?, UserStorageError?) -> Void) {
        storage.saveToFile(data: data, completion: completion)
    }
}
