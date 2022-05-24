//
//  GCDMemoryManagerInterfaceMock.swift
//  ChatAppUnitTests
//
//  Created by Екатерина on 15.05.2022.
//

import Foundation
@testable import ChatApp

final class GCDMemoryManagerInterfaceMock<MemoryObject: Codable>: MemoryManagerProtocol {

    var invokedReadDataFromMemory = false
    var invokedReadDataFromMemoryCount = 0
    var invokedReadDataFromMemoryParameters: String?
    var invokedReadDataFromMemoryParametersList = [String]()
    var stubbedReadDataFromMemoryCompletionResult: (Result<MemoryObject, Error>, Void)?

    func readDataFromMemory(fileName: String, completion: ((Result<MemoryObject, Error>) -> Void)?) {
        invokedReadDataFromMemory = true
        invokedReadDataFromMemoryCount += 1
        invokedReadDataFromMemoryParameters = fileName
        invokedReadDataFromMemoryParametersList.append(fileName)
        if let result = stubbedReadDataFromMemoryCompletionResult {
            completion?(result.0)
        }
    }

    var invokedWriteDataToMemory = false
    var invokedWriteDataToMemoryCount = 0
    var invokedWriteDataToMemoryParameters: (fileName: String, objectToWrite: MemoryObject)?
    var invokedWriteDataToMemoryParametersList = [(fileName: String, objectToWrite: MemoryObject)]()
    var stubbedWriteDataToMemoryCompletionResult: (Result<MemoryObject, Error>, Void)?

    func writeDataToMemory(fileName: String, objectToWrite: MemoryObject, completion: ((Result<MemoryObject, Error>) -> Void)?) {
        invokedWriteDataToMemory = true
        invokedWriteDataToMemoryCount += 1
        invokedWriteDataToMemoryParameters = (fileName, objectToWrite)
        invokedWriteDataToMemoryParametersList.append((fileName, objectToWrite))
        if let result = stubbedWriteDataToMemoryCompletionResult {
            completion?(result.0)
        }
    }
}
