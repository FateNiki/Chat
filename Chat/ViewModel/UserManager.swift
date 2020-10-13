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
    
    var user: User = User(firstName: "Unknow", lastName: "Person")
    
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
            OperationsUserManager.shared.user = self.user
            completion(self.user)
        }
    }
    
    private init() { }
}

class OperationsUserManager: UserManager {
    static let shared = OperationsUserManager()
    
    private class FieldSaveOperation<T>: Operation {
        var field: T?
        var saveClosure: ((T) -> Void)?
        
        override func main() {
            guard let field = field, let saveClosure = saveClosure else { return }
            saveClosure(field)
        }
    }
    
    private class LoadOperation: Operation {
        var loadClosure: (() -> User)?
        var result: User?
        
        override func main() {
            guard let loadClosure = loadClosure else { return }
            result = loadClosure()
        }
    }
        
    var user: User = User(firstName: "Unknow", lastName: "Person")
    
    func saveToFile(data: UserData, completion: @escaping (User) -> Void) {
        let names = data.fullName.split(separator: Character(" "), maxSplits: 2, omittingEmptySubsequences: true)
        
        let firstNameOperation = FieldSaveOperation<String>()
        firstNameOperation.field = names.count > 0 ? String(names[0]) : ""
        firstNameOperation.saveClosure = save(firstName:)
        
        let lastNameOperation = FieldSaveOperation<String>()
        lastNameOperation.field = names.count > 1 ? String(names[1]) : ""
        lastNameOperation.saveClosure = save(lastName:)
        
        let descrOperation = FieldSaveOperation<String>()
        descrOperation.field = data.description
        descrOperation.saveClosure = save(description:)
        
        let avatarOperation = FieldSaveOperation<Data?>()
        avatarOperation.field = data.avatar
        avatarOperation.saveClosure = save(avatar: )
        
        let saveOperation = Operation()
        saveOperation.completionBlock = {
            self.loadFromFile(completion: completion)
        }
        
        saveOperation.addDependency(firstNameOperation)
        saveOperation.addDependency(lastNameOperation)
        saveOperation.addDependency(descrOperation)
        saveOperation.addDependency(avatarOperation)
        
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 4
        queue.addOperations([firstNameOperation, lastNameOperation, descrOperation, avatarOperation, saveOperation], waitUntilFinished: false)
    }
    
    func loadFromFile(completion: @escaping (User) -> Void) {
        let loadOperation = LoadOperation()
        loadOperation.loadClosure = loadUserFromFile
        loadOperation.completionBlock = {
            guard let user = loadOperation.result else { return }
            self.user = user
            completion(user)
        }
        
        let queue = OperationQueue()
        queue.addOperations([loadOperation], waitUntilFinished: false)
    }
    
    private init() { }
}


