//
//  GCDMemoryManagerInterface.swift
//  ChatApp
//
//  Created by Екатерина on 26.04.2022.
//

import Foundation

class GCDMemoryManagerInterface<T: Codable>: MemoryManagerProtocol {
    
    func readDataFromMemory(fileName: String, completion: ((Result<T, Error>) -> Void)?) {
        let GCDLoader = GCDReadFromMemoryManager<T>(plistFileName: fileName) { result in
            completion?(result)
        }
        GCDLoader.getObjectFromMemory()
    }
    
    func writeDataToMemory(fileName: String, objectToWrite: T, completion: ((Result<T, Error>) -> Void)?) {
        let GCDWriter = GCDWriteToMemoryManager(objectToWrite: objectToWrite, plistFileName: fileName) { result in
            completion?(result)
        }
        GCDWriter.loadObjectToMemory()
    }
}
