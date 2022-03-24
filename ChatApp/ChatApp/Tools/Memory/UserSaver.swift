//
//  userSaver.swift
//  ChatApp
//
//  Created by Екатерина on 24.03.2022.
//

import Foundation

func saveUserToMemory(url plistURL: URL?, objectToSave obj: User?, completion: ((Result<User, Error>) -> Void)?) {
    guard let completion = completion else {
        return
    }
    guard let plistURL = plistURL, let obj = obj else {
        completion(.failure(WorkingWithMemoryError.formatError))
        return
    }
    if let data = encodeData(objectToSave: obj, completion: completion) {
        writeDataToFile(url: plistURL, data: data, objectToSave: obj, completion: completion)
    }
}

func encodeData(objectToSave obj: User, completion: (Result<User, Error>) -> Void) -> Data? {
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

func writeDataToFile(url plistURL: URL, data: Data, objectToSave obj: User, completion: (Result<User, Error>) -> Void) {
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
    }
}
