//
//  ChatTests.swift
//  ChatTests
//
//  Created by Алексей Никитин on 30.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//
@testable import Chat
import XCTest

class ChatThemeTests: XCTestCase {

    func testLoadTheme() throws {
        // Arrange
        var result: ThemeName?
        var error: String?
        let themeStorageMock = ThemeStorageMock()
        themeStorageMock.loadWithError = false
        let themeService = ThemeService(storage: themeStorageMock)

        // Act
        themeService.loadAndApply(completion: {
            result = $0
            error = $1
        })
        
        // Assert
        XCTAssertEqual(themeStorageMock.loadAndApplyCalls, 1)
        XCTAssertEqual(themeStorageMock.currentThemeName, result)
        XCTAssertNotNil(result)
        XCTAssertNil(error)
    }
    
    func testLoadThemeWithError() throws {
        // Arrange
        var result: ThemeName?
        var error: String?
        let themeStorageMock = ThemeStorageMock()
        themeStorageMock.loadWithError = true
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
        XCTAssertEqual(error, "loadError")
    }
    
    func testSaveTheme() throws {
        // Arrange
        var error: String?
        var result: ThemeName?
        let themeStorageMock = ThemeStorageMock()
        themeStorageMock.saveWithError = false
        let themeService = ThemeService(storage: themeStorageMock)
        
        // Act
        guard let randomTheme = ThemeName.random() else {
            fatalError("theme doesn't returned")
        }
        themeService.saveAndApply(theme: randomTheme) {
            result = $0
            error = $1
        }
        
        // Assert
        XCTAssertEqual(themeStorageMock.saveAndApplyCalls, 1)
        XCTAssertNotNil(result)
        XCTAssertNil(error)
        XCTAssertEqual(randomTheme, result)
        XCTAssertEqual(randomTheme, themeStorageMock.currentThemeName)
    }
    
    func testSaveThemeWithError() throws {
        // Arrange
        var result: ThemeName?
        var error: String?
        let themeStorageMock = ThemeStorageMock()
        themeStorageMock.saveWithError = true
        let themeService = ThemeService(storage: themeStorageMock)
        
        // Act
        guard let randomTheme = ThemeName.random() else {
            fatalError("theme doesn't returned")
        }
        themeService.saveAndApply(theme: randomTheme) {
            result = $0
            error = $1
        }
        
        // Assert
        XCTAssertEqual(themeStorageMock.saveAndApplyCalls, 1)
        XCTAssertNil(result)
        XCTAssertNotNil(error)
        XCTAssertEqual(error, "saveError")
    }
}
