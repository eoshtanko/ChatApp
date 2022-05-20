//
//  SavingServiceProtocol.swift
//  ChatApp
//
//  Created by Екатерина on 15.05.2022.
//

import Foundation

protocol SavingServiceProtocol {
    associatedtype SavingObject
    func saveWithMemoryManager(obj: SavingObject, complition: ((Result<SavingObject, Error>?) -> Void)?)
    func loadWithMemoryManager(complition: ((Result<SavingObject, Error>?) -> Void)?)
}

// Лучше поздно, чем никогда...
// Protocol can only be used as a generic constraint because it has Self or associated type requirements - бе
class AnyTypeSavingService<SavingObject: Codable>: SavingServiceProtocol {

    typealias SavingObject = SavingObject
    
    private let saveWithMemoryManagerHandler: (SavingObject, ((Result<SavingObject, Error>?) -> Void)?) -> Void
    private let loadWithMemoryManagerHandler: (((Result<SavingObject, Error>?) -> Void)?) -> Void
    
    func saveWithMemoryManager(obj: SavingObject, complition: ((Result<SavingObject, Error>?) -> Void)?) {
        saveWithMemoryManagerHandler(obj, complition)
    }
    
    func loadWithMemoryManager(complition: ((Result<SavingObject, Error>?) -> Void)?) {
        loadWithMemoryManagerHandler(complition)
    }
    
    init<SavingService: SavingServiceProtocol>(sourceSavingService: SavingService) where SavingService.SavingObject == SavingObject {
        saveWithMemoryManagerHandler = sourceSavingService.saveWithMemoryManager
        loadWithMemoryManagerHandler = sourceSavingService.loadWithMemoryManager
    }
}
