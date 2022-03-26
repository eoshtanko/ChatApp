//
//  GCDMemoryManager.swift
//  ChatApp
//
//  Created by Екатерина on 23.03.2022.
//

import Foundation

class GCDMemoryManagerInterface<T: Codable>: MemoryManagerInterfaceProtocol {

    func readDataFromMemory(fileName: String, completionOperation: ((Result<T, Error>?) -> Void)?) {
        let GCDLoader = GCDReadFromMemoryManager<T>(plistFileName: fileName) { result in
            if let completionOperation = completionOperation {
                completionOperation(result)
            }
        }
        GCDLoader.getObjectFromMemory()
    }
    
    func writeDataToMemory(fileName: String, objectToSave: T, completionOperation: ((Result<T, Error>?) -> Void)?) {
        let GCDWriter = GCDWriteToMemoryManager(objectToSave: objectToSave, plistFileName: fileName) { result in
            if let completionOperation = completionOperation {
                completionOperation(result)
            }
        }
        GCDWriter.loadObjectToMemory()
    }
}

fileprivate class GCDMemoryManager<T: Codable> {
    
    // Операция, результат которой отразиться на UI
    fileprivate var completionOperation: ((Result<T, Error>?) -> Void)?
    fileprivate var plistURL: URL!
    
    init(plistFileName: String, completionOperation: ((Result<T, Error>?) -> Void)?) {
        self.plistURL = URL.getPlistURL(plistFileName: plistFileName)
        self.completionOperation = completionOperation
    }
}

fileprivate class GCDWriteToMemoryManager<T: Codable>: GCDMemoryManager<T> {
    // Бессмысленный элемент, но без него компилятор не мог вывести T
    private var objectToSave: T?
    
    init(objectToSave: T, plistFileName: String, completionOperation: ((Result<T, Error>?) -> Void)?) {
        super.init(plistFileName: plistFileName, completionOperation: completionOperation)
        self.objectToSave = objectToSave
    }
    
    func loadObjectToMemory() {
        if objectToSave == nil {
            if let completionOperation = completionOperation {
                completionOperation(.failure(WorkingWithMemoryError.formatError))
            }
            return
        }
        DispatchQueue.global(qos: .background).async {
            writeObjectToMemory(url: self.plistURL, objectToSave: self.objectToSave) { result in
                if let completionOperation = self.completionOperation {
                    completionOperation(result)
                }
            }
        }
    }
}

fileprivate class GCDReadFromMemoryManager<T: Codable>: GCDMemoryManager<T> {
    
    private var objectToRead: T?
    
    func getObjectFromMemory() {
        DispatchQueue.global(qos: .background).async {
            readObjectFromMemory(url: self.plistURL, objectToSave: self.objectToRead) { result in
                if let completionOperation = self.completionOperation {
                    completionOperation(result)
                }
            }
        }
    }
}
