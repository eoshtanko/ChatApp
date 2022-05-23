//
//  ThemeSavingService.swift
//  ChatApp
//
//  Created by Екатерина on 26.04.2022.
//

import Foundation

class SavingService<T: Codable>: SavingServiceProtocol {

    typealias SavingObject = T
    
    private var memoryManager: AnyTypeMemoryManager<T>
    private let fileName: String
    
    init<M: MemoryManagerProtocol>(memoryManager: M, fileName: String) where M.MemoryObject == T {
        self.memoryManager = AnyTypeMemoryManager(sourceMemoryManager: memoryManager)
        self.fileName = fileName
    }
    
    func saveWithMemoryManager(obj: T, complition: ((Result<T, Error>?) -> Void)?) {
        saveWithMemoryManager(memoryManager: memoryManager, obj: obj, complition: complition)
    }
    
    func loadWithMemoryManager(complition: ((Result<T, Error>?) -> Void)?) {
        loadWithMemoryManager(memoryManager: memoryManager, complition: complition)
    }
    
    private func saveWithMemoryManager<M: MemoryManagerProtocol>(memoryManager: M, obj: T, complition: ((Result<T, Error>?) -> Void)?) {
        if let objectToWrite = obj as? M.MemoryObject {
            memoryManager.writeDataToMemory(fileName: fileName, objectToWrite: objectToWrite) { result in
                if let result = result as? Result<T, Error> {
                    complition?(result)
                }
            }
        }
    }
    
    private func loadWithMemoryManager<M: MemoryManagerProtocol>(memoryManager: M, complition: ((Result<T, Error>?) -> Void)?) {
        memoryManager.readDataFromMemory(fileName: fileName) { result in
            if let result = result as? Result<T, Error> {
                complition?(result)
            }
        }
    }
}
