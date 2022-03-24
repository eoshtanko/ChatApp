//
//  GCDMemoryManager.swift
//  ChatApp
//
//  Created by Екатерина on 23.03.2022.
//

import Foundation

class GCDMemoryManager {
    
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
    }
}

class GCDMemoryWriteToMemoryManager: GCDMemoryManager {
    
    private var user: User?
    
    init(objectToSave: User, plistFileName: String, completionOperation: @escaping (Result<User, Error>?) -> Void) {
        super.init(plistFileName: plistFileName, completionOperation: completionOperation)
        self.user = objectToSave
    }
    
    func loadUserToMemory() {
        if user == nil {
            completionOperation(.failure(WorkingWithMemoryError.formatError))
            return
        }
        DispatchQueue.global(qos: .background).async {
            for i in 1...100000000 {
                let y = i + i
            }
            saveUserToMemory(url: self.plistURL, objectToSave: self.user) { result in
                self.completionOperation(result)
            }
        }
    }
}

class GCDMemoryReadFromMemoryManager: GCDMemoryManager {
    
    func getUserFromMemory() {
        DispatchQueue.global(qos: .background).async {
            readUserFromMemory(url: self.plistURL) { result in
                self.completionOperation(result)
            }
        }
    }
}
