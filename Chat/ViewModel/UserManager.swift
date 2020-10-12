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
    var user: User { get }
}

extension UserManager {
    fileprivate func save(firstName: String) {
        guard firstName != user.firstName else { return }
        print(#function)
        user.firstName = firstName
    }
    
    fileprivate func save(lastName: String) {
        guard lastName != user.lastName else { return }
        print(#function)
        user.lastName = lastName
    }
    
    fileprivate func save(description: String) {
        guard description != user.description else { return }
        print(#function)
        user.description = description
    }
    
    fileprivate func save(avatar: Data?) {
        guard avatar != user.avatar else { return }
        print(#function)
        user.avatar = avatar
    }
}

class GCDUserManager: UserManager {
    static let shared = GCDUserManager()
    
    var user: User = User(firstName: "Unknow", lastName: "Persone")
    
    func saveToFile(data: UserData, completion: @escaping (User) -> Void) {
        let group = DispatchGroup()
        
        let names = data.fullName.split(separator: Character(" "), maxSplits: 2, omittingEmptySubsequences: true)
        
        group.enter()
        DispatchQueue.global().async {
            self.save(firstName: names.count > 0 ? String(names[0]) : "")
            group.leave()
        }
        
        group.enter()
        DispatchQueue.global().async {
            self.save(lastName: names.count > 1 ? String(names[1]) : "")
            group.leave()
        }
        
        group.enter()
        DispatchQueue.global().async {
            self.save(description: data.description)
            group.leave()
        }
        
        group.enter()
        DispatchQueue.global().async {
            self.save(avatar: data.avatar)
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(self.user)
        }
    }
    
    func loadFromFile(completion: @escaping (User) -> Void) {
        completion(user)
    }
    
    private init() { }
}

class OperationsUserManager: UserManager {
    static let shared = OperationsUserManager()
    
    var user: User = User(firstName: "Unknow", lastName: "Persone")
    
    func saveToFile(data: UserData, completion: @escaping (User) -> Void) {
        self.user.avatar = data.avatar
        self.user.description = data.description
        let names = data.fullName.split(separator: Character(" "), maxSplits: 2, omittingEmptySubsequences: true)
        self.user.firstName = names.count > 0 ? String(names[0]) : ""
        self.user.lastName = names.count > 1 ? String(names[1]) : ""
        
        completion(self.user)
    }
    
    func loadFromFile(completion: @escaping (User) -> Void) {
        completion(user)
    }
    
    private init() { }
}


