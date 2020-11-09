//
//  GCDUserStorage.swift
//  Chat
//
//  Created by Алексей Никитин on 09.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

class GCDUserStorage: UserStorageProtocol {
    static let shared = GCDUserStorage()
    
    private var errorArray = SafeArray<String>()
    lazy var user: User = {
        return User(id: self.userId)
    }()
    
    func saveToFile(data: UserStorageData, completion: ((User?, [String]?) -> Void)?) {
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        let names = data.fullName.split(separator: Character(" "), maxSplits: 1, omittingEmptySubsequences: true)
        
        errorArray.reset()
        group.enter()
        queue.async {
            do {
                try self.save(firstName: names.count > 0 ? String(names[0]) : "")
            } catch {
                self.errorArray.append(error.localizedDescription)
            }
            group.leave()
        }
        
        group.enter()
        queue.async {
            do {
                try self.save(lastName: names.count > 1 ? String(names[1]) : "")
            } catch {
                self.errorArray.append(error.localizedDescription)
            }
            group.leave()
        }
        
        group.enter()
        queue.async {
            do {
                try self.save(description: data.description)
            } catch {
                self.errorArray.append(error.localizedDescription)
            }
            group.leave()
        }
        
        group.enter()
        queue.async {
            do {
                try self.save(avatar: data.avatar)
            } catch {
                self.errorArray.append(error.localizedDescription)
            }
            group.leave()
        }
        
        group.notify(queue: queue) {
            let errors = self.errorArray.value
            completion?(self.user, errors.isEmpty ? nil : errors)
        }
    }
    
    func loadFromFile(completion: ((User?, [String]?) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.user = self.loadUserFromFile()
            completion?(self.user, nil)
        }
    }
    
    private init() { }
}
