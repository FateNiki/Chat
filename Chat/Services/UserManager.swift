//
//  UserManager.swift
//  Chat
//
//  Created by Алексей Никитин on 10.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

struct UserManagerData {
    let fullName: String
    let description: String
    let avatar: Data?
}

private enum FieldFileName: String {
    case firstName = "userFirstName.txt"
    case lastName = "userLastName.txt"
    case description = "userDescription.txt"
    case avatar = "userAvatar.txt"
}

enum UserSaveError: LocalizedError {
    case firstName(String)
    case lastName(String)
    case description(String)
    case avatar(String)
    
    private var errorMessage: String {
        switch self {
        case let .firstName(message):
            return "Имя: \(message)"
        case let .lastName(message):
            return "Фамилия: \(message)"
        case let .description(message):
            return "Описание: \(message)"
        case let .avatar(message):
            return "Аватар: \(message)"
        }
    }
    
    var errorDescription: String? {
        return errorMessage
    }
}

protocol UserManager: class, FileDataManager where ManagerData == UserManagerData, ManagerResult == User, ManagerError == [String] {
    var user: User { get set }
}

extension UserManager {
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    fileprivate var userId: String {
        let userIdKey = "userId"
        if let userId = UserDefaults.standard.value(forKey: userIdKey) as? String {
            return userId
        } else {
            let userId = UUID().uuidString
            UserDefaults.standard.setValue(userId, forKey: userIdKey)
            UserDefaults.standard.synchronize()
            return userId
        }
    }
    
    fileprivate func loadUserFromFile() -> User {
        let docsDirectory = getDocumentsDirectory()
        let firstNameFile = docsDirectory.appendingPathComponent(FieldFileName.firstName.rawValue)
        let lastNameFile = docsDirectory.appendingPathComponent(FieldFileName.lastName.rawValue)
        let descFile = docsDirectory.appendingPathComponent(FieldFileName.description.rawValue)
        let avatarFile = docsDirectory.appendingPathComponent(FieldFileName.avatar.rawValue)
        
        var user = User(id: self.userId)
        
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
        
        // NOTES
        // Слип для эмуляции долгого чтения из файла
        // Пока идет первая загрузка пользователя - отображается UIActivityIndicatorView
        // Можно закомментировать
//        sleep(2)
        return user
    }
    
    fileprivate func save(firstName: String) throws {
        guard firstName != user.firstName else { return }
        
        let url = getDocumentsDirectory().appendingPathComponent(FieldFileName.firstName.rawValue)
        do {
            try firstName.write(to: url, atomically: true, encoding: .utf8)
            user.firstName = firstName
        } catch {
            throw UserSaveError.firstName(error.localizedDescription)
        }
    }
    
    fileprivate func save(lastName: String) throws {
        guard lastName != user.lastName else { return }
        
        let url = getDocumentsDirectory().appendingPathComponent(FieldFileName.lastName.rawValue)
        do {
            try lastName.write(to: url, atomically: true, encoding: .utf8)
            user.lastName = lastName
        } catch {
            throw UserSaveError.lastName(error.localizedDescription)
        }
    }
    
    fileprivate func save(description: String) throws {
        guard description != user.description else { return }

        let url = getDocumentsDirectory().appendingPathComponent(FieldFileName.description.rawValue)
        do {
            // NOTES: Эти строка можно удалить
            // sleep для эмуляции долгого сохраненеия
            // Далее - рандомная ошибка
            sleep(3)
            if Bool.random() {
                throw ErrorWithMessage(message: "Test error \(Int.random(in: 0...10))")
            }
            try description.write(to: url, atomically: true, encoding: .utf8)
            user.description = description
        } catch {
            throw UserSaveError.description(error.localizedDescription)
        }
    }
    
    fileprivate func save(avatar: Data?) throws {
        guard avatar != user.avatar else { return }
        
        let url = getDocumentsDirectory().appendingPathComponent(FieldFileName.avatar.rawValue)
        if let avatarData = avatar {
            do {
                sleep(5)
                try avatarData.write(to: url)
                user.avatar = avatarData
            } catch {
                throw UserSaveError.avatar(error.localizedDescription)
            }
        } else {
            do {
                try FileManager.default.removeItem(at: url)
                user.avatar = nil
            } catch {
                throw UserSaveError.avatar(error.localizedDescription)
            }
        }
    }
}

class GCDUserManager: UserManager {
    static let shared = GCDUserManager()
    
    private var errorArray = SafeArray<String>()
    lazy var user: User = {
        return User(id: self.userId)
    }()
    
    func saveToFile(data: UserManagerData, completion: ((User?, [String]?) -> Void)?) {
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
            OperationsUserManager.shared.user = self.user
            completion?(self.user, nil)
        }
    }
    
    private init() { }
}

class OperationsUserManager: UserManager {
    static let shared = OperationsUserManager()
    
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
    
    func saveToFile(data: UserManagerData, completion: ((User?, [String]?) -> Void)?) {
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
