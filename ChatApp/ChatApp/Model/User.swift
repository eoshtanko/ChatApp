//
//  User.swift
//  ChatApp
//
//  Created by Екатерина on 07.03.2022.
//

import UIKit

class User: Codable {
    var name: String?
    var info: String?
    var imageData: Data?
    
    init(name: String?, info: String?, imageData: Data?) {
        self.name = name
        self.info = info
        self.imageData = imageData
    }
    
    init(){}
}

struct CurrentUser {
    static var user = User()
}
