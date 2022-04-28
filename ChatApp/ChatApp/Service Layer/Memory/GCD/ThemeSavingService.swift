//
//  ThemeSavingService.swift
//  ChatApp
//
//  Created by Екатерина on 26.04.2022.
//

import Foundation

// Разумеется, это можно обобщить до одного типа UserSavingService, но сейчас 4, а завтра защита
// дублирование кода - плохо.

protocol ThemeSavingServiceProtocol {
    func saveWithMemoryManager(obj: ApplicationPreferences)
    func loadWithMemoryManager(complition: @escaping ((Result<ApplicationPreferences, Error>?) -> Void))
}

class ThemeSavingService: ThemeSavingServiceProtocol {
    private let memoryManager = GCDMemoryManagerInterface<ApplicationPreferences>()
    
    func saveWithMemoryManager(obj: ApplicationPreferences) {
        saveWithMemoryManager(memoryManager: memoryManager, obj: obj)
    }
    
    func loadWithMemoryManager(complition: @escaping ((Result<ApplicationPreferences, Error>?) -> Void)) {
        loadWithMemoryManager(memoryManager: memoryManager, complition: complition)
    }
    
    private func saveWithMemoryManager<M: MemoryManagerProtocol>(memoryManager: M, obj: ApplicationPreferences) {
        if let objectToWrite = obj as? M.MemoryObject {
            memoryManager.writeDataToMemory(fileName: FileNames.plistFileNameForPreferences, objectToWrite: objectToWrite, completion: nil)
        }
    }
    
    private func loadWithMemoryManager<M: MemoryManagerProtocol>(memoryManager: M, complition: @escaping ((Result<ApplicationPreferences, Error>?) -> Void)) {
        memoryManager.readDataFromMemory(fileName: FileNames.plistFileNameForPreferences) { result in
            if let result = result as? Result<ApplicationPreferences, Error> {
                complition(result)
            }
        }
    }
}
