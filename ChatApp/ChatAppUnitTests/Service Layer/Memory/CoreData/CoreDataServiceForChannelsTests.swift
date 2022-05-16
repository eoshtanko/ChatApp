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
    private var channel: Channel!
    
    override func setUp() {
        super.setUp()
        coreDataStackMock = CoreDataStackMock(dataModelName: "")
        channel = Channel(identifier: "", name: "", lastMessage: nil, lastActivity: nil)
    }

    func testSaveChannel() {
        // Arrange
        let service = buildCoreDataService()
        
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
