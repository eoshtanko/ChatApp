//
//  User.swift
//  ChatApp
//
//  Created by Екатерина on 07.03.2022.
//

import UIKit

class User: Codable {
    
    var id: String
    var name: String?
    var info: String?
    var imageData: Data?
    
    init(name: String?, info: String?, imageData: Data?, id: String) {
        self.name = name
        self.info = info
        self.imageData = imageData
        self.id = id
    }
    
    init(id: String) {
        self.id = id
    }
}

struct CurrentUser {
    static var user = createCurrentUser()
    
    static func createCurrentUser() -> User {
        guard let idOfDevice = UIDevice.current.identifierForVendor?.uuidString else {
            Logger.log("Не удалось получить id устройства.", .failure)
            return User(name: nil, info: nil, imageData: nil, id: "")
        }
        return User(id: idOfDevice)
    }
}
