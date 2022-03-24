//
//  Reader.swift
//  ChatApp
//
//  Created by Екатерина on 24.03.2022.
//

import Foundation


func readObjectFromMemory<T: Decodable>(url plistURL: URL?, objectToSave: T?, completion: ((Result<T, Error>) -> Void)?) {
    guard let completion = completion else {
        return
    }
    guard let plistURL = plistURL else {
        completion(.failure(WorkingWithMemoryError.formatError))
        return
    }
    let decoder = PropertyListDecoder()
    guard let data = try? Data.init(contentsOf: plistURL),
          let object = try? decoder.decode(T.self, from: data) else {
              completion(.failure(WorkingWithMemoryError.readError))
              return
          }
    completion(.success(object))
}
