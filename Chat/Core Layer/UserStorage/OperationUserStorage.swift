//
//  OperationUserStorage.swift
//  Chat
//
//  Created by Алексей Никитин on 09.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

class OperationsUserStorage: UserStorageProtocol {
    static let shared = OperationsUserStorage()
    
    private class FieldSaveOperation<T>: Operation {
        var field: T?
        var saveClosure: ((T) throws -> Void)?
        var errorMessage: String?
        
        override func main() {
            guard let field = field, let saveClosure = saveClosure else { return }
            do {
                try saveClosure(field)
            } catch {
                errorMessage = error.localizedDescription
            }
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
    
    private class SaveOperation: Operation {
        var firstNameError: String? {
            let operation = dependencies[0] as? FieldSaveOperation<String>
            return operation?.errorMessage
        }
        var lastNameError: String? {
            let operation = dependencies[1] as? FieldSaveOperation<String>
            return operation?.errorMessage
        }
        var descriptionError: String? {
            let operation = dependencies[2] as? FieldSaveOperation<String>
            return operation?.errorMessage
        }
        var avatarError: String? {
            let operation = dependencies[3] as? FieldSaveOperation<String>
            return operation?.errorMessage
        }
        
        var errors: [String]? {
            if let errors = [firstNameError, lastNameError, descriptionError, avatarError].filter({ $0 != nil }) as? [String] {
                return errors.isEmpty ? nil : errors
            }
            return nil
        }
    }
    
    lazy var user: User = {
        return User(id: self.userId)
    }()
    
    func saveToFile(data: UserStorageData, completion: ((User?, [String]?) -> Void)?) {
        let names = data.fullName.split(separator: Character(" "), maxSplits: 1, omittingEmptySubsequences: true)
        
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
        
        let saveOperation = SaveOperation()
        saveOperation.completionBlock = {
            completion?(self.user, saveOperation.errors)
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
    
    func loadFromFile(completion: ((User?, [String]?) -> Void)?) {
        let loadOperation = LoadOperation()
        loadOperation.loadClosure = loadUserFromFile
        loadOperation.completionBlock = {
            guard let user = loadOperation.result else { return }
            self.user = user
            completion?(user, nil)
        }
        
        let queue = OperationQueue()
        queue.addOperations([loadOperation], waitUntilFinished: false)
    }
    
    private init() { }
}
