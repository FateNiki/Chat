//
//  ThemeStorageMock.swift
//  ChatTests
//
//  Created by Алексей Никитин on 30.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//
@testable import Chat
import Foundation

class ThemeStorageMock: ThemeStorageProtocol {
    // MARK: - Test variable
    private(set) var loadAndApplyCalls = 0
    private(set) var saveAndApplyCalls = 0
    
    // MARK: - Test configure
    public var loadStub: ((((ThemeName?, String?) -> Void)?) -> Void)?
    public var saveStub: ((((ThemeName?, String?) -> Void)?) -> Void)?
    // MARK: - Public variable
    var currentThemeName: ThemeName
    
    init() {
        currentThemeName = .classic
    }
    
    func loadAndApply(completion: ((ThemeName?, String?) -> Void)?) {
        guard let loadStub = loadStub else { return }
        loadAndApplyCalls += 1
        loadStub(completion)
    }
    
    func saveAndApply(theme: ThemeName, completion: ((ThemeName?, String?) -> Void)?) {
        guard let saveStub = saveStub else { return }
        saveAndApplyCalls += 1
        
        currentThemeName = theme
        saveStub(completion)
    }
}
