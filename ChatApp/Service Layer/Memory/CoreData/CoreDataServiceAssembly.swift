//
//  CoreDataServiceAssembly.swift
//  ChatApp
//
//  Created by Екатерина on 15.05.2022.
//

import Foundation

// Правлю недочеты из дз по архитектуре...
class CoreDataServiceAssembly {
    var coreDataServiceForChannels: CoreDataServiceForChannelsProtocol {
        return CoreDataServiceForChannels(coreDataStack: NewCoreDataService(dataModelName: Const.dataModelName))
    }
    
    var coreDataServiceForMessages: CoreDataServiceForMessagesProtocol {
        return CoreDataServiceForMessages(coreDataStack: NewCoreDataService(dataModelName: Const.dataModelName))
    }
    
    enum Const {
        static let dataModelName = "Chat"
    }
}
