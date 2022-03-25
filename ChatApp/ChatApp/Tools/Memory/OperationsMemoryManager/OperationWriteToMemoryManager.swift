//
//  OperationsMemoryManager.swift
//  ChatApp
//
//  Created by Екатерина on 23.03.2022.
//

import UIKit

class OperationMemoryManager<T: Codable>: AsyncOperation {
    
    // Операция, результат которой отразиться на UI
    fileprivate var completionOperation: ((Result<T, Error>?) -> Void)?
    var plistURL: URL!
    
    init(plistFileName: String, completionOperation: ((Result<T, Error>?) -> Void)?) {
        self.plistURL = URL.getPlistURL(plistFileName: plistFileName)
        self.completionOperation = completionOperation
        super.init()
    }
}


class OperationWriteToMemoryManager<T: Codable>: OperationMemoryManager<T> {
    
    private var objectToSave: T?
    
    init(objectToSave: T, plistFileName: String, completionOperation: ((Result<T, Error>?) -> Void)?) {
        super.init(plistFileName: plistFileName, completionOperation: completionOperation)
        self.objectToSave = objectToSave
    }
    
    public override func main() {
        if isCancelled {
            state = .finished
            return
        }
        if objectToSave == nil {
            if let completionOperation = completionOperation {
                completionOperation(.failure(WorkingWithMemoryError.formatError))
            }
            return
        }
        writeObjectToMemory(url: plistURL, objectToSave: objectToSave) { result in
            self.state = .finished
            if let completionOperation = self.completionOperation {
                completionOperation(result)
            }
        }
    }
}

class OperationReadFromMemoryManager<T: Codable>: OperationMemoryManager<T> {
    private var objectToRead: T?
    
    public override func main() {
        if isCancelled {
            state = .finished
            return
        }
        readObjectFromMemory(url: plistURL, objectToSave: objectToRead) { result in
            self.state = .finished
            if let completionOperation = self.completionOperation {
                completionOperation(result)
            }
        }
    }
}
