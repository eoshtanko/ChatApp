//
//  Writer.swift
//  ChatApp
//
//  Created by Екатерина on 24.03.2022.
//

import Foundation

func writeObjectToMemory<T: Encodable>(url plistURL: URL?, objectToSave: T?, completion: ((Result<T, Error>) -> Void)?) {
    guard let completion = completion else {
        return
    }
    guard let plistURL = plistURL, let objectToSave = objectToSave else {
        completion(.failure(WorkingWithMemoryError.formatError))
        return
    }
    if let data = encodeData(objectToSave: objectToSave, completion: completion) {
        writeDataToFile(url: plistURL, data: data, objectToSave: objectToSave, completion: completion)
    }
}

func encodeData<T: Encodable>(objectToSave obj: T, completion: (Result<T, Error>) -> Void) -> Data? {
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

func writeDataToFile<T>(url plistURL: URL, data: Data, objectToSave obj: T, completion: (Result<T, Error>) -> Void) {
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
