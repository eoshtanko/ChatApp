//
//  UserLoader.swift
//  ChatApp
//
//  Created by Екатерина on 24.03.2022.
//

import Foundation


func readUserFromMemory(url plistURL: URL?, completion: ((Result<User, Error>) -> Void)?) {
    guard let completion = completion else {
        return
    }
    guard let plistURL = plistURL else {
        completion(.failure(WorkingWithMemoryError.formatError))
        return
    }
    let decoder = PropertyListDecoder()
    guard let data = try? Data.init(contentsOf: plistURL),
          let user = try? decoder.decode(User.self, from: data) else {
              completion(.failure(WorkingWithMemoryError.readError))
              return
          }
    completion(.success(user))
}
