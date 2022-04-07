//
//  NewCoreDataService.swift
//  ChatApp
//
//  Created by Екатерина on 05.04.2022.
//

import CoreData
import UIKit

final class NewCoreDataService: CoreDataServiceProtocol {
    
    private let dataModelName: String
    
    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: dataModelName)
        container.loadPersistentStores { _, error in
            if let error = error {
                CoreDataLogger.log("Не удалось загрузить постоянные хранилища.", .failure)
            }
        }
        return container
    }()
    
    init(dataModelName: String) {
        self.dataModelName = dataModelName
    }
    
    //    Казалось бы, следовало сделать универсальный метод и для канала и для сообщения ...
    //
    //    func fetchDBChannels<T: NSManagedObject>() -> [T]? {
    //        if let fetchRequest = T.fetchRequest() as? NSFetchRequest<T> {
    //            return try? container.viewContext.fetch(fetchRequest)
    //        }
    //        return nil
    //    }
    //
    //    Но почему-то это отказывается работать "executeFetchRequest:error: A fetch request must have an entity."
    
    func fetchDBChannels() -> [DBChannel]? {
        let fetchRequest = DBChannel.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(DBChannel.lastActivity), ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        guard let dbChannels = try? container.viewContext.fetch(fetchRequest) else {
            CoreDataLogger.log("Не удалось корректно выполнить Channels-fetch-запрос.", .failure)
            return nil
        }
        return dbChannels
    }
    
    func fetchDBChannelById(id: String) -> [DBChannel]? {
        let fetchRequest = DBChannel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", id)
        guard let dbChannel = try? container.viewContext.fetch(fetchRequest) else {
            CoreDataLogger.log("Не удалось корректно выполнить Channel-fetch-запрос.", .failure)
            return nil
        }
        return dbChannel
    }
    
    func performSave<T>(toSave: T, completion: (() -> Void)?, _ block: @escaping (T, NSManagedObjectContext) -> Void) {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSOverwriteMergePolicy
        context.perform {
            block(toSave, context)
            if context.hasChanges {
                do {
                    try self.performSaveContext(in: context)
                    CoreDataLogger.log("Объект был успешно записан в БД: ", toSave)
                    completion?()
                } catch {
                    print(error)
                    CoreDataLogger.log("Не удалось сохранить изменения объектов в родительском хранилище контекста.", .failure)
                }
            }
        }
    }
    
    private func performSaveContext(in context: NSManagedObjectContext) throws {
        try context.save()
        // Не нужно, но мало ли...
        if let parent = context.parent {
            try performSaveContext(in: parent)
        }
    }
}
