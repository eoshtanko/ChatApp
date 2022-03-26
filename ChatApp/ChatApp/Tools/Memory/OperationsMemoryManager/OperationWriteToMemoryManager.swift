//
//  OperationsMemoryManager.swift
//  ChatApp
//
//  Created by Екатерина on 23.03.2022.
//

import UIKit

class OperationMemoryManagerInterface<T: Codable>: MemoryManagerInterfaceProtocol {
    
    private let operationQueue = OperationQueue()
    
    func readDataFromMemory(fileName: String, completionOperation: ((Result<T, Error>?) -> Void)?) {
        let operationLoader = OperationReadFromMemoryManager<T>(plistFileName: fileName) { result in
            if let completionOperation = completionOperation {
                completionOperation(result)
            }
        }
        operationQueue.qualityOfService = .utility
        operationQueue.addOperations(
            [operationLoader],
            waitUntilFinished: false
        )
    }
    
    func writeDataToMemory(fileName: String, objectToSave: T, completionOperation: ((Result<T, Error>?) -> Void)?) {
        let operationWriter = OperationWriteToMemoryManager(objectToSave: objectToSave, plistFileName: fileName) { result in
            if let completionOperation = completionOperation {
                completionOperation(result)
            }
        }
        operationQueue.addOperations([operationWriter], waitUntilFinished: false)
    }
}

fileprivate class OperationMemoryManager<T: Codable>: AsyncOperation {
    
    // Операция, результат которой отразиться на UI
    fileprivate var completionOperation: ((Result<T, Error>?) -> Void)?
    fileprivate var plistURL: URL!
    
    init(plistFileName: String, completionOperation: ((Result<T, Error>?) -> Void)?) {
        self.plistURL = URL.getPlistURL(plistFileName: plistFileName)
        self.completionOperation = completionOperation
        super.init()
    }
}


fileprivate class OperationWriteToMemoryManager<T: Codable>: OperationMemoryManager<T> {
    
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

fileprivate class OperationReadFromMemoryManager<T: Codable>: OperationMemoryManager<T> {
    // Бессмысленный элемент, но без него компилятор не мог вывести T
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
