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
