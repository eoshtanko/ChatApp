//
//  GCDMemoryManager.swift
//  ChatApp
//
//  Created by Екатерина on 23.03.2022.
//

import Foundation

class GCDMemoryManagerInterface<T: Codable>: MemoryManagerProtocol {
    
    func readDataFromMemory(fileName: String, completion: ((Result<T, Error>) -> Void)?) {
        let GCDLoader = GCDReadFromMemoryManager<T>(plistFileName: fileName) { result in
            completion?(result)
        }
        GCDLoader.getObjectFromMemory()
    }
    
    func writeDataToMemory(fileName: String, objectToWrite: T, completion: ((Result<T, Error>) -> Void)?) {
        let GCDWriter = GCDWriteToMemoryManager(objectToWrite: objectToWrite, plistFileName: fileName) { result in
            completion?(result)
        }
        GCDWriter.loadObjectToMemory()
    }
}

private class GCDMemoryManager<T: Codable> {
    fileprivate let dispatchQueue = DispatchQueue.global(qos: .background)
    // Операция, результат которой отразиться на UI
    fileprivate var completionOperation: ((Result<T, Error>) -> Void)?
    fileprivate var plistURL: URL?
    init(plistFileName: String, completionOperation: ((Result<T, Error>) -> Void)?) {
        self.plistURL = URL.getPlistURL(plistFileName: plistFileName)
        self.completionOperation = completionOperation
    }
}

private class GCDWriteToMemoryManager<T: Codable>: GCDMemoryManager<T>, Writer {
    private var objectToWrite: T
    init(objectToWrite: T, plistFileName: String, completionOperation: ((Result<T, Error>) -> Void)?) {
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

private class GCDReadFromMemoryManager<T: Codable>: GCDMemoryManager<T>, Reader {
    // Бессмысленный элемент, но без него компилятор не мог вывести T
    private var objectToRead: T?
    func getObjectFromMemory() {
        dispatchQueue.async {
            self.readObjectFromMemory(url: self.plistURL, objectToRead: self.objectToRead) { result in
                self.completionOperation?(result)
            }
        }
    }
}
