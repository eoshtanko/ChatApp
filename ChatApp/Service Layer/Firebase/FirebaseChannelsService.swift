//
//  FirebaseService.swift
//  ChatApp
//
//  Created by Екатерина on 26.04.2022.
//

import Foundation
import Firebase

protocol FirebaseChannelsServiceProtocol {
    func configureSnapshotListener(failAction: @escaping (() -> Void))
    func createNewChannel(name: String, failAction: @escaping ((String) -> Void))
    func removeChannelFromFirebase(withID id: String, failAction: ((String) -> Void)?)
    var reference: CollectionReference { get }
}

class FirebaseChannelsService: FirebaseChannelsServiceProtocol {
    lazy var db = Firestore.firestore()
    lazy var reference = db.collection("channels")
    let coreDataService: CoreDataServiceForChannelsProtocol?
    
    init(coreDataService: CoreDataServiceForChannelsProtocol) {
        self.coreDataService = coreDataService
    }
    
    func configureSnapshotListener(failAction: @escaping (() -> Void)) {
        reference.addSnapshotListener { snapshot, error in
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
        guard let channel = Channel(document: change.document) else {
            return
        }
        switch change.type {
        case .added, .modified:
            coreDataService?.saveChannel(channel: channel)
        case .removed:
            coreDataService?.deleteChannel(channel: channel)
        }
    }
    
    func createNewChannel(name: String, failAction: @escaping ((String) -> Void)) {
        let channel = Channel(name: name)
        reference.addDocument(data: channel.toDict) { error in
            if error != nil {
                failAction(name)
                return
            }
        }
    }
    
    func removeChannelFromFirebase(withID id: String, failAction: ((String) -> Void)?) {
        reference.document(id).delete { err in
            if err != nil {
                failAction?(id)
            }
        }
    }
}
