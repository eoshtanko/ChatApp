//
//  ProfileDataSavingService.swift
//  ChatApp
//
//  Created by Екатерина on 26.04.2022.
//

import Foundation

class UserSavingService {
    private let memoryManager = GCDMemoryManagerInterface<User>()
    
    func saveWithMemoryManager(obj: User, complition: @escaping ((Result<User, Error>?) -> Void)) {
        saveWithMemoryManager(memoryManager: memoryManager, obj: obj, complition: complition)
    }
    
    func loadWithMemoryManager(complition: @escaping ((Result<User, Error>?) -> Void)) {
        loadWithMemoryManager(memoryManager: memoryManager, complition: complition)
    }
    
    private func saveWithMemoryManager<M: MemoryManagerProtocol>(memoryManager: M, obj: User, complition: @escaping ((Result<User, Error>?) -> Void)) {
        if let objectToWrite = obj as? M.MemoryObject {
            memoryManager.writeDataToMemory(fileName: FileNames.plistFileNameForProfileInfo, objectToWrite: objectToWrite) { result in
                complition(result as? Result<User, Error>)
            }
        }
    }
    
    private func loadWithMemoryManager<M: MemoryManagerProtocol>(memoryManager: M, complition: @escaping ((Result<User, Error>?) -> Void)) {
        memoryManager.readDataFromMemory(fileName: FileNames.plistFileNameForProfileInfo) { result in
            if let result = result as? Result<User, Error> {
                complition(result)
            }
        }
    }
}
