//
//  MemoryManagerInterface.swift
//  ChatApp
//
//  Created by Екатерина on 26.03.2022.
//

import Foundation

protocol MemoryManagerInterfaceProtocol {
    
    associatedtype MemoryObject: Codable
    func readDataFromMemory(fileName: String, completionOperation: ((Result<MemoryObject, Error>) -> Void)?)
    func writeDataToMemory(fileName: String, objectToWrite: MemoryObject, completionOperation: ((Result<MemoryObject, Error>) -> Void)?)
}
