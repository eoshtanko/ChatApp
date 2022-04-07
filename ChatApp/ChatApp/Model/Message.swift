//
//  ChatMessage.swift
//  ChatApp
//
//  Created by Екатерина on 09.03.2022.
//

import Foundation
import Firebase

struct Message {
    
    let content: String
    let created: Date
    let senderId: String
    let senderName: String
    
    init(content: String, senderId: String, senderName: String, created: Date) {
        self.content = content
        self.senderId = senderId
        self.senderName = senderName
        self.created = created
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let content = data["content"] as? String,
              let senderId = data["senderId"] as? String,
              let senderName = data["senderName"] as? String,
              let created = data["created"] as? Timestamp else {
                  return nil
              }
        
        self.content = content
        self.senderId = senderId
        self.senderName = senderName
        self.created = created.dateValue()
    }
}

extension Message {
    
    var toDict: [String: Any] {
        return ["content": content,
                "created": created,
                "senderId": senderId,
                "senderName": senderName]
    }
}

extension Message: Comparable {
    
  static func < (lhs: Message, rhs: Message) -> Bool {
      return lhs.created < rhs.created
  }
}

extension Message: StringConvertableProtocol {
    func toString() -> String {
        return "Message(content: \(content), senderId: \(senderId))."
    }
}
