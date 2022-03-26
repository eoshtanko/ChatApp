//
//  MemoryManagerInterface.swift
//  ChatApp
//
//  Created by Екатерина on 26.03.2022.
//

import Foundation

protocol MemoryManagerInterfaceProtocol {
    
    associatedtype T: Codable
    
    func readDataFromMemory(fileName: String, completionOperation: ((Result<T, Error>?) -> Void)?)
    func writeDataToMemory(fileName: String, objectToSave: T, completionOperation: ((Result<T, Error>?) -> Void)?)
}
