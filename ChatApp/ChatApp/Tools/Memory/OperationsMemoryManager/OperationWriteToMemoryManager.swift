//
//  OperationsMemoryManager.swift
//  ChatApp
//
//  Created by Екатерина on 23.03.2022.
//

import UIKit

class OperationMemoryManager: AsyncOperation, UserLoadOperations {
    
    internal fileprivate(set) var result: Result<User, Error>?
    // Операция, результат которой отразиться на UI
    fileprivate var completionOperation: (Result<User, Error>?) -> Void
    private let plistFileName: String
    
    var plistURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent(plistFileName)
    }
    
    init(plistFileName: String, completionOperation: @escaping (Result<User, Error>?) -> Void) {
        self.plistFileName = plistFileName
        self.completionOperation = completionOperation
        super.init()
    }
}

class OperationWriteToMemoryManager: OperationMemoryManager {
    
    private var user: User?
    
    init(objectToSave: User, plistFileName: String, completionOperation: @escaping (Result<User, Error>?) -> Void) {
        super.init(plistFileName: plistFileName, completionOperation: completionOperation)
        self.user = objectToSave
    }
    
    public override func main() {
        if isCancelled {
            state = .finished
            return
        }
        if user == nil {
            completionOperation(.failure(WorkingWithMemoryError.formatError))
            return
        }
        saveUserToMemory(url: plistURL, objectToSave: user!) { [weak self] result in
            self?.result = result
            self?.state = .finished
            self?.completionOperation(result)
        }
    }
}

class OperationReadFromMemoryManager: OperationMemoryManager {
    
    public override func main() {
        if isCancelled {
            state = .finished
            return
        }
        readUserFromMemory(url: plistURL) { [weak self] result in
            self?.result = result
            self?.state = .finished
            self?.completionOperation(result)
        }
    }
}
