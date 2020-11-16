//
//  ThemeService.swift
//  Chat
//
//  Created by Алексей Никитин on 11.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

protocol ThemeServiceProtocol {
    var currentThemeName: ThemeName { get }
    func loadAndApply(completion: ((ThemeName?, String?) -> Void)?)
    func saveAndApply(theme: ThemeName, completion: ((ThemeName?, String?) -> Void)?)
}

class ThemeService: ThemeServiceProtocol {
    private let storage: ThemeStorageProtocol
    var currentThemeName: ThemeName { storage.currentThemeName }
    
    init(storage: ThemeStorageProtocol) {
        self.storage = storage
    }
    
    func loadAndApply(completion: ((ThemeName?, String?) -> Void)?) {
        storage.loadAndApply(completion: completion)
    }
    
    func saveAndApply(theme: ThemeName, completion: ((ThemeName?, String?) -> Void)?) {
        storage.saveAndApply(theme: theme, completion: completion)
    }
}
