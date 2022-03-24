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
    private let plistFileName: String
    
    var plistURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent(plistFileName)
    }
    
    init(plistFileName: String, completionOperation: ((Result<T, Error>?) -> Void)?) {
        self.plistFileName = plistFileName
        self.completionOperation = completionOperation
    }
}

class GCDMemoryWriteToMemoryManager<T: Codable>: GCDMemoryManager<T> {
    
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

class GCDMemoryReadFromMemoryManager<T: Codable>: GCDMemoryManager<T> {
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
