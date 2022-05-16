//
//  ChatAppUITests.swift
//  ChatAppUITests
//
//  Created by Екатерина on 16.05.2022.
//

import XCTest

/*
 Почему не Snapshot тесты, которые были на лекции???
 
 Snapshot тесты — это тесты, которые делают скриншот экрана (эталонный скриншот)
 и сравнивают с актуальным скриншотом, который делается во время прогона тестов.
 Делать Snapshot тесты на все возможные проверки кажется плохой практикой, так как если будет редизайн,
 наши тесты моментально станут красными, и придется в срочном порядке менять эталонные скриншоты.
 Наверное, использование Snapshot тестов хорошо для проверки верстки, элементов,
 с которыми тяжело взаимодействовать по accessibilityidentifier, но это не наш случай.
 */
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
        app.navigationBars["Channels"].buttons["goToProfileNavBarButton"].tap()
    }
    
    override func tearDown() {
        // На самом деле, он и без вызова данной функции завершает приложение
        // Для порядку...
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
