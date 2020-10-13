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

fileprivate enum FieldFileName: String {
    case firstName = "userFirstName.txt"
    case lastName = "userLastName.txt"
    case description = "userDescription.txt"
    case avatar = "userAvatar.txt"
}

protocol UserManager: DataManager where ManagerData == UserData, ManagerResult == User {
    var user: User { get }
}

extension UserManager {
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    fileprivate func loadUserFromFile() -> User {
        let docsDirectory = getDocumentsDirectory()
        let firstNameFile = docsDirectory.appendingPathComponent(FieldFileName.firstName.rawValue)
        let lastNameFile = docsDirectory.appendingPathComponent(FieldFileName.lastName.rawValue)
        let descFile = docsDirectory.appendingPathComponent(FieldFileName.description.rawValue)
        let avatarFile = docsDirectory.appendingPathComponent(FieldFileName.avatar.rawValue)
        
        let user = User(firstName: "", lastName: "")
        
        if let firstName = try? String(contentsOf: firstNameFile, encoding: .utf8) {
            user.firstName = firstName
        }
        
        if let lastName = try? String(contentsOf: lastNameFile, encoding: .utf8) {
            user.lastName = lastName
        }
        
        if let description = try? String(contentsOf: descFile, encoding: .utf8) {
            user.description = description
        }
        
        if let avatar = try? Data(contentsOf: avatarFile) {
            user.avatar = avatar
        }
        
        sleep(5)
        
        return user
    }
    
    fileprivate func save(firstName: String) {
        guard firstName != user.firstName else { return }
        print(#function)
        
        let url = getDocumentsDirectory().appendingPathComponent(FieldFileName.firstName.rawValue)
        do {
            try firstName.write(to: url, atomically: true, encoding: .utf8)
            user.firstName = firstName
        } catch {
            print(error)
        }
    }
    
    fileprivate func save(lastName: String) {
        guard lastName != user.lastName else { return }
        print(#function)
        
        let url = getDocumentsDirectory().appendingPathComponent(FieldFileName.lastName.rawValue)
        do {
            try lastName.write(to: url, atomically: true, encoding: .utf8)
            user.lastName = lastName
        } catch {
            print(error)
        }
    }
    
    fileprivate func save(description: String) {
        guard description != user.description else { return }
        print(#function)

        let url = getDocumentsDirectory().appendingPathComponent(FieldFileName.description.rawValue)
        do {
            try description.write(to: url, atomically: true, encoding: .utf8)
            user.description = description
        } catch {
            print(error)
        }
    }
    
    fileprivate func save(avatar: Data?) {
        guard avatar != user.avatar else { return }
        print(#function)
        
        let url = getDocumentsDirectory().appendingPathComponent(FieldFileName.avatar.rawValue)
        if let avatarData = avatar {
            do {
                try avatarData.write(to: url)
                user.avatar = avatarData
            } catch {
                print(error)
            }
        } else {
            do {
                try FileManager.default.removeItem(at: url)
                user.avatar = nil
            } catch {
                print(error)
            }
        }
    }
}

class GCDUserManager: UserManager {
    static let shared = GCDUserManager()
    
    private(set) var user: User = User(firstName: "Unknow", lastName: "Person")
    
    func saveToFile(data: UserData, completion: @escaping (User) -> Void) {
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        let names = data.fullName.split(separator: Character(" "), maxSplits: 2, omittingEmptySubsequences: true)
        
        group.enter()
        queue.async {
            self.save(firstName: names.count > 0 ? String(names[0]) : "")
            group.leave()
        }
        
        group.enter()
        queue.async {
            self.save(lastName: names.count > 1 ? String(names[1]) : "")
            group.leave()
        }
        
        group.enter()
        queue.async {
            self.save(description: data.description)
            group.leave()
        }
        
        group.enter()
        queue.async {
            self.save(avatar: data.avatar)
            group.leave()
        }
        
        group.notify(queue: queue) {
            self.loadFromFile(completion: completion)
        }
    }
    
    func loadFromFile(completion: @escaping (User) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.user = self.loadUserFromFile()
            completion(self.user)
        }
    }
    
    private init() { }
}

class OperationsUserManager: UserManager {
    static let shared = OperationsUserManager()
    
    var user: User = User(firstName: "Unknow", lastName: "Person")
    
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


