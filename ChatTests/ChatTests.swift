//
//  ChatTests.swift
//  ChatTests
//
//  Created by Алексей Никитин on 30.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//
@testable import Chat
import XCTest

extension ThemeName {
    static func random() -> ThemeName? {
        ThemeName.allCases.randomElement()
    }
}

class ChatThemeTests: XCTestCase {

    func testLoadTheme() throws {
        // Arrange
        let loadedTheme = ThemeName.random()!
        var result: ThemeName?
        var error: String?
        let themeStorageMock = ThemeStorageMock()
        themeStorageMock.loadStub = { completion in
            themeStorageMock.currentThemeName = loadedTheme
            completion?(loadedTheme, nil)
        }
        let themeService = ThemeService(storage: themeStorageMock)
        
        // Act
        themeService.loadAndApply(completion: {
            result = $0
            error = $1
        })
        
        // Assert
        XCTAssertEqual(themeStorageMock.loadAndApplyCalls, 1)
        XCTAssertNotNil(result)
        XCTAssertNil(error)
        XCTAssertEqual(loadedTheme, result)
        XCTAssertEqual(themeStorageMock.currentThemeName, result)
    }
    
    func testLoadThemeWithError() throws {
        // Arrange
        let errorString = "loadError"
        var result: ThemeName?
        var error: String?
        let themeStorageMock = ThemeStorageMock()
        themeStorageMock.loadStub = { completion in
            completion?(nil, errorString)
        }
        let themeService = ThemeService(storage: themeStorageMock)
        
        // Act
        themeService.loadAndApply(completion: {
            result = $0
            error = $1
        })
        
        // Assert
        XCTAssertEqual(themeStorageMock.loadAndApplyCalls, 1)
        XCTAssertNil(result)
        XCTAssertNotNil(error)
        XCTAssertEqual(error, errorString)
    }
    
    func testSaveTheme() throws {
        // Arrange
        let savedTheme = ThemeName.random()!
        var error: String?
        var result: ThemeName?
        let themeStorageMock = ThemeStorageMock()
        themeStorageMock.saveStub = { completion in
            completion?(themeStorageMock.currentThemeName, nil)
        }
        let themeService = ThemeService(storage: themeStorageMock)
        
        // Act
        themeService.saveAndApply(theme: savedTheme) {
            result = $0
            error = $1
        }
        
        // Assert
        XCTAssertEqual(themeStorageMock.saveAndApplyCalls, 1)
        XCTAssertNotNil(result)
        XCTAssertNil(error)
        XCTAssertEqual(savedTheme, result)
        XCTAssertEqual(savedTheme, themeStorageMock.currentThemeName)
    }
    
    func testSaveThemeWithError() throws {
        // Arrange
        let errorString = "saveError"
        var result: ThemeName?
        var error: String?
        let themeStorageMock = ThemeStorageMock()
        themeStorageMock.saveStub = { completion in
            completion?(nil, errorString)
        }
        let themeService = ThemeService(storage: themeStorageMock)
        
        // Act
        themeService.saveAndApply(theme: ThemeName.random()!) {
            result = $0
            error = $1
        }
        
        // Assert
        XCTAssertEqual(themeStorageMock.saveAndApplyCalls, 1)
        XCTAssertNil(result)
        XCTAssertNotNil(error)
        XCTAssertEqual(error, errorString)
    }
}
