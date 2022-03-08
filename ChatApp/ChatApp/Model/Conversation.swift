//
//  File.swift
//  ChatApp
//
//  Created by Екатерина on 06.03.2022.
//

import UIKit

struct Conversation {
    var name: String?
    var message: String?
    var date: Date?
    var online: Bool
    var hasUnreadMessages: Bool
    // Ну как же можно без картинки? Без картиники нехорошо.
    var image: UIImage?
}
