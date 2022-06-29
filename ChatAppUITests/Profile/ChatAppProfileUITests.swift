//
//  ChatAppUITests.swift
//  ChatAppUITests
//
//  Created by Екатерина on 16.05.2022.
//

import XCTest

class ChatAppProfileUITests: XCTestCase {
    
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
        // Переходим на экран профиля
        app.navigationBars["Channels"].children(matching: .button).element(boundBy: 2).tap()
    }
    
    override func tearDown() {
        app.terminate()
        super.tearDown()
    }

    func testPresensOfProfileElements() throws {
        // Arrange
        let title = app.staticTexts["profileTitle"]
        let closeProfileButton = app.buttons["closeProfileButton"]
        let profileImage = app.images["profileImage"]
        let nameTextField = app.textFields["nameTextField"]
        let aboutMeTextView = app.textViews["aboutMeTextField"]
        let editPhotoButton = app.buttons["editPhotoButton"]
        let editProfileInfoButton = app.buttons["editButton"]
        
        // Act
        _ = title.waitForExistence(timeout: 10)
        
        // Assert
        XCTAssertTrue(title.exists)
        XCTAssertTrue(closeProfileButton.exists)
        XCTAssertTrue(profileImage.exists)
        XCTAssertTrue(nameTextField.exists)
        XCTAssertTrue(aboutMeTextView.exists)
        XCTAssertTrue(editPhotoButton.exists)
        XCTAssertTrue(editProfileInfoButton.exists)
    }
    
    func testPresensOfButtonsInEditMode() {
        // Arrange
        let editProfileInfoButton = app.buttons["editButton"]
        let saveProfileInfoButton = app.buttons["saveButton"]
        let cancelEditingProfileInfoButton = app.buttons["cancelButton"]
        
        // Act
        _ = editProfileInfoButton.waitForExistence(timeout: 10)
        editProfileInfoButton.tap()
        _ = saveProfileInfoButton.waitForExistence(timeout: 10)
        
        // Assert
        XCTAssertTrue(saveProfileInfoButton.exists)
        XCTAssertTrue(cancelEditingProfileInfoButton.exists)
        XCTAssertFalse(editProfileInfoButton.exists)
    }
    
    func testPresensOfImageSourceOptions() {
        // Arrange
        let editPhotoButton = app.buttons["editPhotoButton"]
        let imageSources = app.sheets["Image Source"].scrollViews.otherElements
        
        // Act
        _ = editPhotoButton.waitForExistence(timeout: 10)
        editPhotoButton.tap()
        _ = imageSources.buttons["Cancel"].waitForExistence(timeout: 10)
        
        // Assert
        XCTAssertTrue(imageSources.buttons["Photo Library"].exists)
        XCTAssertTrue(imageSources.buttons["Camera"].exists)
        XCTAssertTrue(imageSources.buttons["Upload"].exists)
        XCTAssertTrue(imageSources.buttons["Cancel"].exists)
    }
}
