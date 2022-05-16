//
//  ChatAppUnitTests.swift
//  ChatAppUnitTests
//
//  Created by Екатерина on 15.05.2022.
//

import XCTest
@testable import ChatApp

// Протестируем вызов метода performTaskOnMainQueueContextAndSave core слоя
class CoreDataServiceForChannelsTests: XCTestCase {
    
    private var coreDataStackMock: CoreDataStackMock!
    
    override func setUp() {
        super.setUp()
        coreDataStackMock = CoreDataStackMock(dataModelName: "")
    }

    func testSaveChannel() {
        // Arrange
        let service = buildCoreDataService()
        let channel = Channel(identifier: "", name: "", lastMessage: nil, lastActivity: nil)
        
        // Act
        service.saveChannel(channel: channel)
        
        // Assert
        XCTAssertTrue(coreDataStackMock.invokedPerformTaskOnMainQueueContextAndSave)
        XCTAssertEqual(coreDataStackMock.invokedPerformTaskOnMainQueueContextAndSaveCount, 1)
    }
    
    private func buildCoreDataService() -> CoreDataServiceForChannels {
        return CoreDataServiceForChannels(coreDataStack: coreDataStackMock)
    }
}
