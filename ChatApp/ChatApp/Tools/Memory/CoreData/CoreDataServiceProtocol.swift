//
//  CoreDataServiceProtocol.swift
//  ChatApp
//
//  Created by Екатерина on 05.04.2022.
//

import CoreData

protocol CoreDataServiceProtocol {
    
    init(dataModelName: String)
    var viewContext: NSManagedObjectContext { get }
    func performTaskOnMainQueueContextAndSave(_ block: @escaping (NSManagedObjectContext) -> Void)
    func fetchDBChannelById(id: String) -> [DBChannel]?
}

// Работа с каналами.
extension CoreDataServiceProtocol {
    
    func getNSFetchedResultsControllerForChannels() -> NSFetchedResultsController<DBChannel> {
        return NSFetchedResultsController(fetchRequest: getChannelsFetchRequest(),
                                          managedObjectContext: viewContext,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }
    
    private func getChannelsFetchRequest() -> NSFetchRequest<DBChannel> {
        let fetchRequest = DBChannel.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(DBChannel.lastActivity), ascending: false)
        ]
        return fetchRequest
    }
    
    func saveChannel(channel: Channel) {
        performTaskOnMainQueueContextAndSave { context in
            saveChannelToDB(channel: channel, context: context)
        }
    }
    
    func deleteChannel(channel: Channel) {
        if let dbChannelArr = fetchDBChannelById(id: channel.identifier), !dbChannelArr.isEmpty {
            let objectID = dbChannelArr[0].objectID
            performTaskOnMainQueueContextAndSave { context in
                if let dbChannel = context.object(with: objectID) as? DBChannel {
                    context.delete(dbChannel)
                } else {
                    CoreDataLogger.log("В БД находятся ошибочные данные.", .failure)
                }
            }
        }
    }
    
    private func saveChannelToDB(channel: Channel, context: NSManagedObjectContext) {
        guard let dbChannel = DBChannel(usedContext: context) else {
            CoreDataLogger.log("Не удалось создать объект DBChannel.", .failure)
            return
        }
        dbChannel.identifier = channel.identifier
        dbChannel.name = channel.name
        dbChannel.lastMessage = channel.lastMessage
        dbChannel.lastActivity = channel.lastActivity
    }
    
    func parseDBChannelToChannel(_ dbChannel: DBChannel) throws -> Channel {
        guard let identifier = dbChannel.identifier, let name = dbChannel.name else {
            throw WorkingWithMemoryError.formatError
        }
        return Channel(identifier: identifier,
                       name: name,
                       lastMessage: dbChannel.lastMessage,
                       lastActivity: dbChannel.lastActivity)
    }
}

// Работа с сообщениями.
extension CoreDataServiceProtocol {
    
    func getNSFetchedResultsControllerForMessages(channelId: String?) -> NSFetchedResultsController<DBMessage>? {
        guard let id = channelId else {
            CoreDataLogger.log("ID канала - nil.", .failure)
            return nil
        }
        return NSFetchedResultsController(fetchRequest: getMessagesFetchRequest(id),
                                          managedObjectContext: viewContext,
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
            CoreDataLogger.log("Канал не инициализирован.", .failure)
            return
        }
        if let dbChannelArr = fetchDBChannelById(id: channel.identifier), !dbChannelArr.isEmpty {
            let objectID = dbChannelArr[0].objectID
            performTaskOnMainQueueContextAndSave { context in
                if let dbChannel = context.object(with: objectID) as? DBChannel {
                    saveMessageToDB(message: message, id: id, channel: dbChannel, context: context)
                } else {
                    CoreDataLogger.log("В БД находятся ошибочные данные.", .failure)
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
            CoreDataLogger.log("Не удалось создать объект DBMessage.", .failure)
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
