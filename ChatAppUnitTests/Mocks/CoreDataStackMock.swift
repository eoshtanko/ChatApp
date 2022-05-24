//
//  CoreDataStackMock.swift
//  ChatAppUnitTests
//
//  Created by Екатерина on 15.05.2022.
//

import Foundation
import CoreData
@testable import ChatApp

final class CoreDataStackMock: CoreDataServiceProtocol {

    required init(dataModelName: String) {}

    var invokedViewContextGetter = false
    var invokedViewContextGetterCount = 0
    var stubbedViewContext: NSManagedObjectContext!

    var viewContext: NSManagedObjectContext {
        invokedViewContextGetter = true
        invokedViewContextGetterCount += 1
        return stubbedViewContext
    }

    var invokedPerformTaskOnMainQueueContextAndSave = false
    var invokedPerformTaskOnMainQueueContextAndSaveCount = 0
    var stubbedPerformTaskOnMainQueueContextAndSaveBlockResult: (NSManagedObjectContext, Void)?

    func performTaskOnMainQueueContextAndSave(_ block: @escaping (NSManagedObjectContext) -> Void) {
        invokedPerformTaskOnMainQueueContextAndSave = true
        invokedPerformTaskOnMainQueueContextAndSaveCount += 1
        if let result = stubbedPerformTaskOnMainQueueContextAndSaveBlockResult {
            block(result.0)
        }
    }

    var invokedFetchDBChannelById = false
    var invokedFetchDBChannelByIdCount = 0
    var invokedFetchDBChannelByIdParameters: (id: String, Void)?
    var invokedFetchDBChannelByIdParametersList = [(id: String, Void)]()
    var stubbedFetchDBChannelByIdResult: [DBChannel]!

    func fetchDBChannelById(id: String) -> [DBChannel]? {
        invokedFetchDBChannelById = true
        invokedFetchDBChannelByIdCount += 1
        invokedFetchDBChannelByIdParameters = (id, ())
        invokedFetchDBChannelByIdParametersList.append((id, ()))
        return stubbedFetchDBChannelByIdResult
    }
}
