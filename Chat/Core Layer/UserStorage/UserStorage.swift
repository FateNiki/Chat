//
//  UserStorage.swift
//  Chat
//
//  Created by Алексей Никитин on 09.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

struct UserStorageData {
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

protocol UserStorageProtocol: class {
    func loadFromFile(completion: ((User?, [String]?) -> Void)?)
    func saveToFile(data: UserStorageData, completion: ((User?, [String]?) -> Void)?)
    
    var user: User { get set }
}

extension UserStorageProtocol {
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    var userId: String {
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
    
    func loadUserFromFile() -> User {
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
    
    func save(firstName: String) throws {
        guard firstName != user.firstName else { return }
        
        let url = getDocumentsDirectory().appendingPathComponent(FieldFileName.firstName.rawValue)
        do {
            try firstName.write(to: url, atomically: true, encoding: .utf8)
            user.firstName = firstName
        } catch {
            throw UserSaveError.firstName(error.localizedDescription)
        }
    }
    
    func save(lastName: String) throws {
        guard lastName != user.lastName else { return }
        
        let url = getDocumentsDirectory().appendingPathComponent(FieldFileName.lastName.rawValue)
        do {
            try lastName.write(to: url, atomically: true, encoding: .utf8)
            user.lastName = lastName
        } catch {
            throw UserSaveError.lastName(error.localizedDescription)
        }
    }
    
    func save(description: String) throws {
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
    
    func save(avatar: Data?) throws {
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
