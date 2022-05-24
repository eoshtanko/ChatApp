//
//  FirebaseMessagesService.swift
//  ChatApp
//
//  Created by Екатерина on 26.04.2022.
//

import Foundation
import Firebase

// Разумеется, это можно обобщить до одного типа FirebaseChannelsService, но сейчас 4, а завтра защита
// дублирование кода - плохо.
protocol FirebaseMessagesServiceProtocol {
    func configureSnapshotListener(failAction: @escaping (() -> Void))
    func sendMessage(message: Message, failAction: @escaping (() -> Void), successAction: @escaping (() -> Void))
}

// Это неправильно. Service Layer не должен знать о модели (Presentation Layer), Нужно сделать все на дженериках
class FirebaseMessagesService: FirebaseMessagesServiceProtocol {

    private let channel: Channel?
    private let dbChannelReference: CollectionReference
    lazy var reference: CollectionReference? = {
        guard let channel = channel else {
            return nil
        }
        let channelIdentifier = channel.identifier
        return dbChannelReference.document(channelIdentifier).collection("messages")
    }()
    
    let coreDataService: CoreDataServiceForMessagesProtocol?
    
    init(coreDataService: CoreDataServiceForMessagesProtocol, dbChannelReference: CollectionReference, channel: Channel?) {
        self.coreDataService = coreDataService
        self.dbChannelReference = dbChannelReference
        self.channel = channel
    }
    
    func configureSnapshotListener(failAction: @escaping (() -> Void)) {
        reference?.addSnapshotListener { snapshot, error in
            guard error == nil, let snapshot = snapshot else {
                failAction()
                return
            }
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let message = Message(document: change.document) else {
            return
        }
        switch change.type {
        case .added:
            coreDataService?.saveMessage(message: message, channel: channel, id: change.document.documentID)
        case .removed, .modified:
            return
        }
    }
    
    func sendMessage(message: Message, failAction: @escaping (() -> Void), successAction: @escaping (() -> Void)) {
        reference?.addDocument(data: message.toDict) { error in
            if error != nil {
                failAction()
                return
            }
            successAction()
        }
    }
}
