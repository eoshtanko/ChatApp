//
//  File.swift
//  ChatApp
//
//  Created by Екатерина on 06.03.2022.
//

import UIKit
import Firebase

struct Channel {
    
    let identifier: String
    let name: String
    let lastMessage: String?
    let lastActivity: Date?
    
    init(identifier: String, name: String, lastMessage: String?, lastActivity: Date?) {
        self.name = name
        self.identifier = identifier
        self.lastMessage = lastMessage
        self.lastActivity = lastActivity
    }
    
    init(name: String) {
        self.init(identifier: "111", name: name, lastMessage: nil, lastActivity: nil)
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let name = data["name"] as? String,
              let lastMessage = data["lastMessage"] as? String,
              let lastActivity = data["lastActivity"] as? Timestamp else {
                  return nil
              }
        
        self.init(identifier: document.documentID,
                  name: name,
                  lastMessage: lastMessage,
                  lastActivity: lastActivity.dateValue())
    }
}

extension Channel {
    
    var toDict: [String: Any] {
        return ["name": name, "lastMessage": "", "lastActivity": Date()]
    }
}

extension Channel: Comparable {
    
    static func == (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    static func < (lhs: Channel, rhs: Channel) -> Bool {
        guard let lhsDate = lhs.lastActivity, let rhsDate = rhs.lastActivity else {
            return false
        }
        return lhsDate > rhsDate
    }
}

extension Channel: StringConvertableProtocol {
    func toString() -> String {
        return "Channel(name: \(name), id: \(identifier))."
    }
}
