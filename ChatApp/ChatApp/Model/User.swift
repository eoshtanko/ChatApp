//
//  User.swift
//  ChatApp
//
//  Created by Екатерина on 07.03.2022.
//

import UIKit

class User {
    var name: String?
    var info: String?
    var image: UIImage?
}

struct CurrentUser {
    static let user = User()
}
