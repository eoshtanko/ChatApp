//
//  Writer.swift
//  ChatApp
//
//  Created by Екатерина on 24.03.2022.
//

import Foundation

protocol Writer {
    func writeObjectToMemory<T: Encodable>(url plistURL: URL?, objectToWrite: T?, completion: ((Result<T, Error>) -> Void)?)
    func encodeData<T: Encodable>(objectToWrite obj: T, completion: (Result<T, Error>) -> Void) -> Data?
    func writeDataToFile<T>(url plistURL: URL, data: Data, objectToWrite obj: T, completion: (Result<T, Error>) -> Void)
}

extension Writer {
    
    func writeObjectToMemory<T: Encodable>(url plistURL: URL?, objectToWrite: T?, completion: ((Result<T, Error>) -> Void)?) {
        guard let completion = completion else {
            return
        }
        guard let plistURL = plistURL, let objectToWrite = objectToWrite else {
            completion(.failure(WorkingWithMemoryError.formatError))
            return
        }
        if let data = encodeData(objectToWrite: objectToWrite, completion: completion) {
            writeDataToFile(url: plistURL, data: data, objectToWrite: objectToWrite, completion: completion)
        }
    }
    
    func encodeData<T: Encodable>(objectToWrite obj: T, completion: (Result<T, Error>) -> Void) -> Data? {
        let encoder = PropertyListEncoder()
        var data: Data
        do {
            data = try encoder.encode(obj)
            return data
        } catch {
            completion(.failure(WorkingWithMemoryError.formatError))
            return nil
        }
    }
    
    func writeDataToFile<T>(url plistURL: URL, data: Data, objectToWrite obj: T, completion: (Result<T, Error>) -> Void) {
        if FileManager.default.fileExists(atPath: plistURL.path) {
            do {
                try data.write(to: plistURL)
                completion(.success(obj))
            } catch {
                completion(.failure(WorkingWithMemoryError.writeError))
                return
            }
        } else {
            FileManager.default.createFile(atPath: plistURL.path, contents: data, attributes: nil)
            completion(.success(obj))
        }
    }
}
