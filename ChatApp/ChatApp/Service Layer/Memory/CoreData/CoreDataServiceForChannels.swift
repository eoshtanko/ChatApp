//
//  CoreDataServiceForChannels.swift
//  ChatApp
//
//  Created by Екатерина on 26.04.2022.
//

import Foundation
import CoreData

// Разумеется, это можно обобщить до одного типа CoreDataServiceForMessages, но сейчас 4, а завтра защита
protocol CoreDataServiceForChannelsProtocol {
    func fetchedResultsController(viewController: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<DBChannel>?
    func saveChannel(channel: Channel)
    func deleteChannel(channel: Channel)
    func parseDBChannelToChannel(_ dbChannel: DBChannel) throws -> Channel
}

class CoreDataServiceForChannels: CoreDataServiceForChannelsProtocol {
    
    let coreDataStack: CoreDataServiceProtocol?

    init(dataModelName: String) {
        coreDataStack = NewCoreDataService(dataModelName: dataModelName)
    }
    
    func fetchedResultsController(viewController: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<DBChannel>? {
        guard let controller = getNSFetchedResultsController() else {
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
    
    private func getNSFetchedResultsController() -> NSFetchedResultsController<DBChannel>? {
        guard let coreDataStack = coreDataStack else {
            return nil
        }
        return NSFetchedResultsController(fetchRequest: getChannelsFetchRequest(),
                                          managedObjectContext: coreDataStack.viewContext,
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
        coreDataStack?.performTaskOnMainQueueContextAndSave { context in
            self.saveChannelToDB(channel: channel, context: context)
        }
    }
    
    func deleteChannel(channel: Channel) {
        if let dbChannelArr = coreDataStack?.fetchDBChannelById(id: channel.identifier), !dbChannelArr.isEmpty {
            let objectID = dbChannelArr[0].objectID
            coreDataStack?.performTaskOnMainQueueContextAndSave { context in
                if let dbChannel = context.object(with: objectID) as? DBChannel {
                    context.delete(dbChannel)
                } else {
                    Logger.log("В БД находятся ошибочные данные.", .failure)
                }
            }
        }
    }
    
    private func saveChannelToDB(channel: Channel, context: NSManagedObjectContext) {
        guard let dbChannel = DBChannel(usedContext: context) else {
            Logger.log("Не удалось создать объект DBChannel.", .failure)
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
