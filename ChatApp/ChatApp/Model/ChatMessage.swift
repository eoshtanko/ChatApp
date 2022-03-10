//
//  ChatMessage.swift
//  ChatApp
//
//  Created by Екатерина on 09.03.2022.
//

import Foundation

// Не совсем поняла, нужно ли было прописывать этот протокол из
// задания. На всякий случай пропишу.
protocol MessageCellConfiguration: AnyObject {
    var text: String? {get set}
}

// И я бы сделала это struct, но чтобы перестраховаться и
// явно реализовать протокол из ТЗ, сделаю классом:
class ChatMessage: MessageCellConfiguration {
    var text: String?
    var isIncoming: Bool
    var date: Date?
    
    init(text: String?, isIncoming: Bool, date: Date?) {
        self.text = text
        self.isIncoming = isIncoming
        self.date = date
    }
}
