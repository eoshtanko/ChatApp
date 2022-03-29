//
//  OperationsMemoryManager.swift
//  ChatApp
//
//  Created by Екатерина on 23.03.2022.
//

import UIKit

class OperationMemoryManagerInterface<T: Codable>: MemoryManagerInterfaceProtocol {
    
    private let operationQueue = OperationQueue()
    
    func readDataFromMemory(fileName: String, completionOperation: ((Result<T, Error>) -> Void)?) {
        let operationLoader = OperationReadFromMemoryManager<T>(plistFileName: fileName) { result in
            completionOperation?(result)
        }
        operationQueue.qualityOfService = .utility
        operationQueue.addOperations(
            [operationLoader],
            waitUntilFinished: false
        )
    }
    
    func writeDataToMemory(fileName: String, objectToWrite: T, completionOperation: ((Result<T, Error>) -> Void)?) {
        let operationWriter = OperationWriteToMemoryManager(objectToWrite: objectToWrite, plistFileName: fileName) { result in
            completionOperation?(result)
        }
        operationQueue.addOperations([operationWriter], waitUntilFinished: false)
    }
}

fileprivate class OperationMemoryManager<T: Codable>: AsyncOperation {
    
    // Операция, результат которой отразиться на UI
    fileprivate var completionOperation: ((Result<T, Error>) -> Void)?
    fileprivate var plistURL: URL?
    
    init(plistFileName: String, completionOperation: ((Result<T, Error>) -> Void)?) {
        self.plistURL = URL.getPlistURL(plistFileName: plistFileName)
        self.completionOperation = completionOperation
        super.init()
    }
}


fileprivate class OperationWriteToMemoryManager<T: Codable>: OperationMemoryManager<T>, Writer {
    
    private var objectToWrite: T
    
    init(objectToWrite: T, plistFileName: String, completionOperation: ((Result<T, Error>) -> Void)?) {
        self.objectToWrite = objectToWrite
        super.init(plistFileName: plistFileName, completionOperation: completionOperation)
    }
    
    public override func main() {
        if isCancelled {
            state = .finished
            return
        }
        writeObjectToMemory(url: plistURL, objectToWrite: objectToWrite) { result in
            self.state = .finished
            self.completionOperation?(result)
        }
    }
}

fileprivate class OperationReadFromMemoryManager<T: Codable>: OperationMemoryManager<T>, Reader {
    // Бессмысленный элемент, но без него компилятор не мог вывести T
    private var objectToRead: T?
    
    public override func main() {
        if isCancelled {
            state = .finished
            return
        }
        readObjectFromMemory(url: plistURL, objectToRead: objectToRead) { result in
            self.state = .finished
            self.completionOperation?(result)
        }
    }
}
