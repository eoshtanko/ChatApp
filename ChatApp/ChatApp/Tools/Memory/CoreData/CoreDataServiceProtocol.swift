//
//  CoreDataServiceProtocol.swift
//  ChatApp
//
//  Created by Екатерина on 05.04.2022.
//

import CoreData

protocol CoreDataServiceProtocol {
    
    init(dataModelName: String)
    func fetchDBChannels() -> [DBChannel]?
    func fetchDBChannelById(id: String) -> [DBChannel]?
    func performSave<T>(toSave: T, completion: (() -> Void)?, _ block: @escaping (T, NSManagedObjectContext) -> Void)
    func performDelete<T>(toDelete: T, completion: (() -> Void)?, _ block: @escaping (NSManagedObjectContext) -> Void)
}

// Работа с каналами.
extension CoreDataServiceProtocol {
    
    func saveChannel(channel: Channel, _ updateChannels: (() -> Void)?) {
        performSave(toSave: channel, completion: updateChannels) { channel, context in
            saveChannelToDB(channel: channel, context: context)
        }
    }
    
    func deleteChannel(channel: Channel, _ updateChannels: (() -> Void)?) {
        if let dbChannelArr = fetchDBChannelById(id: channel.identifier), !dbChannelArr.isEmpty {
            performDelete(toDelete: channel, completion: updateChannels) { context in
                let objectID = dbChannelArr[0].objectID
                if let dbChannel = context.object(with: objectID) as? DBChannel {
                    context.delete(dbChannel)
                } else {
                    CoreDataLogger.log("В БД находятся ошибочные данные.", .failure)
                }
            }
        }
    }
    
    func readChannelsFromDB() -> [Channel] {
        var channels = [Channel]()
        
        if let dbChannels: [DBChannel] = fetchDBChannels() {
            for dbChannel in dbChannels {
                do {
                    let channel = try parseDBChannelToChannel(dbChannel)
                    channels.append(channel)
                    CoreDataLogger.log("Канал был успешно прочитан из БД: ", channel)
                } catch {
                    CoreDataLogger.log("Не удалось распарсить прочтенный канал.", .failure)
                }
            }
        }
        return channels
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
    
    private func parseDBChannelToChannel(_ dbChannel: DBChannel) throws -> Channel {
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
    
    func saveMessage(message: Message, channel: Channel) {
        if let dbChannelArr = fetchDBChannelById(id: channel.identifier), !dbChannelArr.isEmpty {
            performSave(toSave: message, completion: nil) { message, context in
                let objectID = dbChannelArr[0].objectID
                if let dbChannel = context.object(with: objectID) as? DBChannel {
                    saveMessageToDB(message: message, channel: dbChannel, context: context)
                } else {
                    CoreDataLogger.log("В БД находятся ошибочные данные.", .failure)
                }
            }
        }
    }
    
    func readMessagesFromDB(channel: Channel) -> [Message] {
        guard let dbChannelArr = fetchDBChannelById(id: channel.identifier), !dbChannelArr.isEmpty else {
            return []
        }
        guard let dbMessages = dbChannelArr[0].messages else {
            CoreDataLogger.log("В БД находятся ошибочные данные.", .failure)
            return []
        }
        
        var messages = [Message]()
        for dbMessage in dbMessages {
            guard let dbMessage = dbMessage as? DBMessage else {
                CoreDataLogger.log("В БД находятся ошибочные данные.", .failure)
                return []
            }
            do {
                let message = try parseDBMessageToMessage(dbMessage)
                messages.append(message)
                CoreDataLogger.log("Сообщение было успешно прочитано из БД: ", message)
            } catch {
                CoreDataLogger.log("Не удалось распарсить прочтенное сообщение.", .failure)
            }
        }
        return messages.sorted()
    }
    
    private func saveMessageToDB(message: Message, channel: DBChannel, context: NSManagedObjectContext) {
        if let dbMessage = configureDBMessage(message: message, context: context) {
            channel.addToMessages(dbMessage)
        }
    }

    private func parseDBMessageToMessage(_ dbMessage: DBMessage) throws -> Message {
        guard let content = dbMessage.content, let created = dbMessage.created,
              let senderId = dbMessage.senderId, let senderName = dbMessage.senderName else {
                  throw WorkingWithMemoryError.formatError
              }
        return Message(content: content,
                       senderId: senderId,
                       senderName: senderName,
                       created: created)
    }
    
    private func configureDBMessage(message: Message, context: NSManagedObjectContext) -> DBMessage? {
        guard let dbMessage = DBMessage(usedContext: context) else {
            CoreDataLogger.log("Не удалось создать объект DBMessage.", .failure)
            return nil
        }
        dbMessage.content = message.content
        dbMessage.created = message.created
        dbMessage.senderId = message.senderId
        dbMessage.senderName = message.senderName
        return dbMessage
    }
}
