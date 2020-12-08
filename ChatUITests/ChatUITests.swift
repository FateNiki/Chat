//
//  ChatUITests.swift
//  ChatUITests
//
//  Created by Алексей Никитин on 01.12.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import XCTest

class ChatUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        sleep(3)

        // let userProfileButton = app.otherElements["userProfileButton"]
        // XCTAssert(userProfileButton.waitForExistence(timeout: 1))
        // userProfileButton.tap()
        
        // XCTAssertTrue(app.textFields["userNameField"].exists)
        // XCTAssertTrue(app.textViews["userDescriptionView"].exists)

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}
