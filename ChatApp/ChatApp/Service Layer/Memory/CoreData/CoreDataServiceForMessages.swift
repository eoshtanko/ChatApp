//
//  CoreDataServiceForMessages.swift
//  ChatApp
//
//  Created by Екатерина on 26.04.2022.
//

import Foundation
import CoreData

class CoreDataServiceForMessages {
    
    let coreDataStack: CoreDataServiceProtocol?

    init(dataModelName: String) {
        coreDataStack = NewCoreDataService(dataModelName: dataModelName)
    }
    
    func fetchedResultsController(viewController: NSFetchedResultsControllerDelegate, id: String?) -> NSFetchedResultsController<DBMessage>? {
        guard let controller = getNSFetchedResultsController(channelId: id) else {
            return nil
        }
        controller.delegate = viewController
        do {
            try controller.performFetch()
        } catch {
            Logger.log("Ошибка при попытке выполнить Fetch-запрос.", .failure)
        }
        return controller
    }
    
    private func getNSFetchedResultsController(channelId: String?) -> NSFetchedResultsController<DBMessage>? {
        guard let id = channelId else {
            Logger.log("ID канала - nil.", .failure)
            return nil
        }
        guard let coreDataStack = coreDataStack else {
            return nil
        }
        return NSFetchedResultsController(fetchRequest: getMessagesFetchRequest(id),
                                          managedObjectContext: coreDataStack.viewContext,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }
    
    private func getMessagesFetchRequest(_ channelId: String) -> NSFetchRequest<DBMessage> {
        let fetchRequest = DBMessage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "channel.identifier == %@", channelId)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(DBMessage.created), ascending: true)
        ]
        return fetchRequest
    }
    
    func saveMessage(message: Message, channel: Channel?, id: String) {
        guard let channel = channel else {
            Logger.log("Канал не инициализирован.", .failure)
            return
        }
        if let dbChannelArr = coreDataStack?.fetchDBChannelById(id: channel.identifier), !dbChannelArr.isEmpty {
            let objectID = dbChannelArr[0].objectID
            coreDataStack?.performTaskOnMainQueueContextAndSave { context in
                if let dbChannel = context.object(with: objectID) as? DBChannel {
                    self.saveMessageToDB(message: message, id: id, channel: dbChannel, context: context)
                } else {
                    Logger.log("В БД находятся ошибочные данные.", .failure)
                }
            }
        }
    }
    
    private func saveMessageToDB(message: Message, id: String, channel: DBChannel, context: NSManagedObjectContext) {
        if let dbMessage = configureDBMessage(message: message, id: id, context: context) {
            channel.addToMessages(dbMessage)
        }
    }
    
    func parseDBMessageToMessage(_ dbMessage: DBMessage?) throws -> Message {
        guard let dbMessage = dbMessage, let content = dbMessage.content,
                let created = dbMessage.created, let senderId = dbMessage.senderId,
                let senderName = dbMessage.senderName else {
                  throw WorkingWithMemoryError.formatError
              }
        return Message(content: content,
                       senderId: senderId,
                       senderName: senderName,
                       created: created)
    }
    
    private func configureDBMessage(message: Message, id: String, context: NSManagedObjectContext) -> DBMessage? {
        guard let dbMessage = DBMessage(usedContext: context) else {
            Logger.log("Не удалось создать объект DBMessage.", .failure)
            return nil
        }
        dbMessage.content = message.content
        dbMessage.created = message.created
        dbMessage.senderId = message.senderId
        dbMessage.senderName = message.senderName
        dbMessage.identifier = id
        return dbMessage
    }
}
