//
//  UserViewModel.swift
//  Chat
//
//  Created by Алексей Никитин on 09.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

protocol UserViewModelProtocol: class {
    var delegate: UserViewModelDelegate? { get set }
    
    func loadUser()
    func resetUserChanges()
    func saveUser(data: UserStorageData)
    func needSave(data: UserStorageData) -> Bool
}

protocol UserViewModelDelegate: class {
    func userDidReset(user: User)
    
    func userWillLoad()
    func userDidLoad(user: User)
    func showLoadingError(errors: UserStorageError)
    
    func userWillSave()
    func userDidSave(user: User)
    func retrySave(errors: UserStorageError)
}

class UserViewModel: UserViewModelProtocol {
    private var userService: UserServiceProtocol
    weak var delegate: UserViewModelDelegate?
    private var user: User?
    
    init(userService: UserServiceProtocol) {
        self.userService = userService
    }
    
    func saveUser(data: UserStorageData) {
        guard let delegate = delegate else { return }
        delegate.userWillSave()
        
        userService.saveUser(data: data) { [weak delegate] (user, errors) in
            guard let delegate = delegate else { return }
            if let user = user {
                self.user = user
                delegate.userDidSave(user: user)
            } else if let errors = errors {
                delegate.retrySave(errors: errors)
            }
        }
    }
    
    func loadUser() {
        guard let delegate = delegate else { return }
        delegate.userWillLoad()
        
        userService.getUser { [weak delegate] (user, errors) in
            guard let delegate = delegate else { return }
            if let user = user {
                self.user = user
                delegate.userDidLoad(user: user)
            } else if let errors = errors {
                delegate.showLoadingError(errors: errors)
            }
        }
    }
    
    func resetUserChanges() {
        guard let delegate = delegate, let user = user else { return }
        delegate.userDidReset(user: user)
    }
    
    func needSave(data: UserStorageData) -> Bool {
        guard let user = user else { return false }
        
        let equal = data.fullName == user.fullName &&
            data.description == user.description &&
            data.avatar == user.avatar
        return !equal
    }
}
