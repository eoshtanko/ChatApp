//
//  Reader.swift
//  ChatApp
//
//  Created by Екатерина on 24.03.2022.
//

import Foundation

protocol Reader {
    func readObjectFromMemory<T: Decodable>(url plistURL: URL?,
                                            objectToRead: T?,
                                            completion: ((Result<T, Error>) -> Void)?)
}

extension Reader {
    func readObjectFromMemory<T: Decodable>(url plistURL: URL?,
                                            objectToRead: T?,
                                            completion: ((Result<T, Error>) -> Void)?) {
        guard let completion = completion else {
            return
        }
        guard let plistURL = plistURL else {
            completion(.failure(WorkingWithMemoryError.formatError))
            return
        }
        let decoder = PropertyListDecoder()
        do {
            let data = try Data(contentsOf: plistURL)
            let object = try decoder.decode(T.self, from: data)
            completion(.success(object))
        } catch {
            completion(.failure(WorkingWithMemoryError.readError))
        }
    }
}
