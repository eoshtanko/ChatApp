//
//  MemoryManagerInterface.swift
//  ChatApp
//
//  Created by Екатерина on 26.03.2022.
//

import Foundation

protocol MemoryManagerProtocol {
    associatedtype MemoryObject: Codable
    func readDataFromMemory(fileName: String, completion: ((Result<MemoryObject, Error>) -> Void)?)
    func writeDataToMemory(fileName: String, objectToWrite: MemoryObject, completion: ((Result<MemoryObject, Error>) -> Void)?)
}

class AnyTypeMemoryManager<MemoryObject: Codable>: MemoryManagerProtocol {
    
    typealias MemoryObject = MemoryObject
    
    private let readDataFromMemoryHandler: (String, ((Result<MemoryObject, Error>) -> Void)?) -> Void
    private let writeDataToMemoryHandler: (String, MemoryObject, ((Result<MemoryObject, Error>) -> Void)?) -> Void
    
    func readDataFromMemory(fileName: String, completion: ((Result<MemoryObject, Error>) -> Void)?) {
        readDataFromMemoryHandler(fileName, completion)
    }
    
    func writeDataToMemory(fileName: String, objectToWrite: MemoryObject, completion: ((Result<MemoryObject, Error>) -> Void)?) {
        writeDataToMemoryHandler(fileName, objectToWrite, completion)
    }
    
    init<MemoryManager: MemoryManagerProtocol>(sourceMemoryManager: MemoryManager) where MemoryManager.MemoryObject == MemoryObject {
        readDataFromMemoryHandler = sourceMemoryManager.readDataFromMemory
        writeDataToMemoryHandler = sourceMemoryManager.writeDataToMemory
    }
}
