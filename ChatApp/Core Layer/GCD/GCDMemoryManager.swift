//
//  GCDMemoryManager.swift
//  ChatApp
//
//  Created by Екатерина on 23.03.2022.
//

import Foundation

protocol WriteToMemoryManager {
    associatedtype OBJ: Codable
    func loadObjectToMemory()
    init(objectToWrite: OBJ, plistFileName: String, completionOperation: ((Result<OBJ, Error>) -> Void)?)
}

protocol ReadFromMemoryManager {
    associatedtype OBJ: Codable
    func getObjectFromMemory()
}

class GCDMemoryManager<T: Codable> {
    
    fileprivate let dispatchQueue = DispatchQueue.global(qos: .background)
    fileprivate var completionOperation: ((Result<T, Error>) -> Void)?
    fileprivate var plistURL: URL?
    init(plistFileName: String, completionOperation: ((Result<T, Error>) -> Void)?) {
        self.plistURL = URL.getPlistURL(plistFileName: plistFileName)
        self.completionOperation = completionOperation
    }
}

class GCDWriteToMemoryManager<T: Codable>: GCDMemoryManager<T>, Writer, WriteToMemoryManager {
    typealias OBJ = T
    
    private var objectToWrite: T
    required init(objectToWrite: T, plistFileName: String, completionOperation: ((Result<T, Error>) -> Void)?) {
        self.objectToWrite = objectToWrite
        super.init(plistFileName: plistFileName, completionOperation: completionOperation)
    }
    func loadObjectToMemory() {
        dispatchQueue.async {
            self.writeObjectToMemory(url: self.plistURL, objectToWrite: self.objectToWrite) { result in
                self.completionOperation?(result)
            }
        }
    }
}

class GCDReadFromMemoryManager<T: Codable>: GCDMemoryManager<T>, Reader, ReadFromMemoryManager {
    typealias OBJ = T
    
    private var objectToRead: T?
    func getObjectFromMemory() {
        dispatchQueue.async {
            self.readObjectFromMemory(url: self.plistURL, objectToRead: self.objectToRead) { result in
                self.completionOperation?(result)
            }
        }
    }
}
