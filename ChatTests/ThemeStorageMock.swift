//
//  ThemeStorageMock.swift
//  ChatTests
//
//  Created by Алексей Никитин on 30.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//
@testable import Chat
import Foundation

extension ThemeName {
    static func random() -> ThemeName? {
        ThemeName.allCases.randomElement()        
    }
}

class ThemeStorageMock: ThemeStorageProtocol {
    // MARK: - Test variable
    private(set) var loadAndApplyCalls = 0
    private(set) var saveAndApplyCalls = 0
    
    // MARK: - Test configure
    public var loadWithError: Bool = false
    public var saveWithError: Bool = false
    
    // MARK: - Public variable
    private(set) var currentThemeName: ThemeName
    
    init() {
        currentThemeName = .classic
    }
    
    func loadAndApply(completion: ((ThemeName?, String?) -> Void)?) {
        loadAndApplyCalls += 1
        if loadWithError {
            completion?(nil, "loadError")
        } else if let randomTheme = ThemeName.random() {
            currentThemeName = randomTheme
            completion?(currentThemeName, nil)
        }
    }
    
    func saveAndApply(theme: ThemeName, completion: ((ThemeName?, String?) -> Void)?) {
        saveAndApplyCalls += 1
        if saveWithError {
            completion?(nil, "saveError")
        } else {
            currentThemeName = theme
            completion?(theme, nil)
        }
    }
}
