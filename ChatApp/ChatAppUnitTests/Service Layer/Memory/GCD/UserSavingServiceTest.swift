//
//  UserSavingServiceTest.swift
//  ChatAppUnitTests
//
//  Created by Екатерина on 15.05.2022.
//

import XCTest
@testable import ChatApp

// Протестируем вызовы методов readDataFromMemory и writeDataToMemory core слоя
class UserSavingServiceTest: XCTestCase {
    
    private var gcdMemoryManagerMock: GCDMemoryManagerInterfaceMock<User>!
    
    override func setUp() {
        super.setUp()
        gcdMemoryManagerMock = GCDMemoryManagerInterfaceMock<User>()
    }

    func testReadUser() {
        // Arrange
        let service = buildUserSavingService()
        let expectedParameters = Const.fileName
        
        // Act
        service.loadWithMemoryManager(complition: nil)
        
        // Assert
        XCTAssertTrue(gcdMemoryManagerMock.invokedReadDataFromMemory)
        XCTAssertEqual(gcdMemoryManagerMock.invokedReadDataFromMemoryCount, 1)
        XCTAssertEqual(gcdMemoryManagerMock.invokedReadDataFromMemoryParameters, expectedParameters)
        XCTAssertEqual(gcdMemoryManagerMock.invokedReadDataFromMemoryParametersList.count, 1)
    }
    
    func testWriteUser() {
        // Arrange
        let service = buildUserSavingService()
        let user = User(id: "")
        let expectedParameters = (Const.fileName, user)
        
        // Act
        service.saveWithMemoryManager(obj: user, complition: nil)
        
        // Assert
        XCTAssertTrue(gcdMemoryManagerMock.invokedWriteDataToMemory)
        XCTAssertEqual(gcdMemoryManagerMock.invokedWriteDataToMemoryCount, 1)
        
        XCTAssertNotNil(gcdMemoryManagerMock.invokedWriteDataToMemoryParameters)
        if let params = gcdMemoryManagerMock.invokedWriteDataToMemoryParameters {
        XCTAssertEqual(params.fileName, Const.fileName)
        XCTAssertEqual(params.objectToWrite, user)
            XCTAssertTrue(params == expectedParameters, "Параметры не совпадают: \(params) и \(expectedParameters)")
        }
        XCTAssertEqual(gcdMemoryManagerMock.invokedWriteDataToMemoryParametersList.count, 1)
    }
    
    private func buildUserSavingService() -> SavingService<User> {
        return SavingService<User>(memoryManager: gcdMemoryManagerMock, fileName: Const.fileName)
    }
    
    private enum Const {
        static let fileName = "Test File Name"
    }
}
