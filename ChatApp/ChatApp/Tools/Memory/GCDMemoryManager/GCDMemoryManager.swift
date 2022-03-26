//
//  GCDMemoryManager.swift
//  ChatApp
//
//  Created by Екатерина on 23.03.2022.
//

import Foundation

class GCDMemoryManager<T: Codable> {
    
    // Операция, результат которой отразиться на UI
    fileprivate var completionOperation: ((Result<T, Error>?) -> Void)?
    fileprivate var plistURL: URL!
    
    init(plistFileName: String, completionOperation: ((Result<T, Error>?) -> Void)?) {
        self.plistURL = URL.getPlistURL(plistFileName: plistFileName)
        self.completionOperation = completionOperation
    }
}

class GCDWriteToMemoryManager<T: Codable>: GCDMemoryManager<T> {
    
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

class GCDReadFromMemoryManager<T: Codable>: GCDMemoryManager<T> {
    
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
