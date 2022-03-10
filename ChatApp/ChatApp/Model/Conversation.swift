//
//  File.swift
//  ChatApp
//
//  Created by Екатерина on 06.03.2022.
//

import UIKit

// Не совсем поняла, нужно ли было прописывать этот протокол из
// задания. На всякий случай пропишу.
protocol ConversationCellConfiguration: AnyObject {
    var name: String? {get set}
    var message: String? {get set}
    var date: Date? {get set}
    var online: Bool {get set}
    var hasUnreadMessages: Bool {get set}
}

// И я бы сделала это struct, но чтобы перестраховаться и
// явно реализовать протокол из ТЗ, сделаю классом:
class Conversation: ConversationCellConfiguration {
    var name: String?
    var message: String?
    var date: Date?
    var online: Bool
    var hasUnreadMessages: Bool
    // Ну как же можно без картинки? Без картиники нехорошо.
    var image: UIImage?
    
    init(name: String?, message: String?, date: Date?, online: Bool, hasUnreadMessages: Bool, image: UIImage?) {
        self.name = name
        self.message = message
        self.date = date
        self.online = online
        self.hasUnreadMessages = hasUnreadMessages
        self.image = image
    }
}
