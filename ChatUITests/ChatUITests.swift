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
        
        let userProfileButton = app.otherElements["userProfileButton"]
        let exist = NSPredicate(format: "exists == 1")
        expectation(for: exist, evaluatedWith: userProfileButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        userProfileButton.tap()
        
        XCTAssertTrue(app.textFields["userNameField"].exists)
        XCTAssertTrue(app.textViews["userDescriptionView"].exists)

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}
