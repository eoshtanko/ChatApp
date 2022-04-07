//
//  OldCoreDataService.swift
//  ChatApp
//
//  Created by Екатерина on 05.04.2022.
//

import CoreData

// [weak self]

final class OldCoreDataService: CoreDataServiceProtocol {
    
    private let dataModelName: String
    
    private lazy var managedObjectModel: NSManagedObjectModel? = {
        if let modelURL = Bundle.main.url(forResource: dataModelName, withExtension: "momd") {
            return NSManagedObjectModel(contentsOf: modelURL)
        }
        CoreDataLogger.log("Не удалось получить url модели данных.", .failure)
        return nil
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        guard let managedObjectModel = managedObjectModel else {
            CoreDataLogger.log("Не удалось получить managedObjectModel.", .failure)
            return nil
        }
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        let fileManager = FileManager.default
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let storeName = dataModelName + ".sqlite"
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        
        do {
            try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: persistentStoreURL
            )
        } catch {
            CoreDataLogger.log("Не удалось добавить постоянное хранилище в указанное местоположение.", .failure)
            return nil
        }
        return coordinator
    }()
    
    private lazy var readContext: NSManagedObjectContext? = {
        guard let persistentStoreCoordinator = persistentStoreCoordinator else {
            CoreDataLogger.log("Не удалось получить NSPersistentStoreCoordinator.", .failure)
            return nil
        }
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        return context
    }()
    
    private lazy var writeContext: NSManagedObjectContext? = {
        guard let persistentStoreCoordinator = persistentStoreCoordinator else {
            CoreDataLogger.log("Не удалось получить NSPersistentStoreCoordinator.", .failure)
            return nil
        }
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        context.mergePolicy = NSOverwriteMergePolicy
        return context
    }()
    
    init(dataModelName: String) {
        self.dataModelName = dataModelName
    }
    
    //    Казалось бы, следовало сделать универсальный метод и для канала и для сообщения ...
    //
    //    func fetchDBChannels<T: NSManagedObject>() -> [T]? {
    //        if let fetchRequest = T.fetchRequest() as? NSFetchRequest<T> {
    //            return try? readContext?.fetch(fetchRequest)
    //        }
    //        return nil
    //    }
    //
    //    Но почему-то это отказывается работать "executeFetchRequest:error: A fetch request must have an entity."
    
    func fetchDBChannels() -> [DBChannel]? {
        let fetchRequest = DBChannel.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(DBChannel.lastActivity), ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        guard let dbChannels = try? readContext?.fetch(fetchRequest) else {
            CoreDataLogger.log("Не удалось корректно выполнить fetch-запрос.", .failure)
            return nil
        }
        return dbChannels
    }
    
    func fetchDBChannelById(id: String) -> [DBChannel]? {
        let fetchRequest = DBChannel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", id)
        guard let dbChannel = try? readContext?.fetch(fetchRequest) else {
            CoreDataLogger.log("Не удалось корректно выполнить Channel-fetch-запрос.", .failure)
            return nil
        }
        return dbChannel
    }
    
    func performSave<T>(toSave: T, completion: (() -> Void)?, _ block: @escaping (T, NSManagedObjectContext) -> Void) {
        guard let context = writeContext else {
            return
        }
        
        context.perform {
            block(toSave, context)
            if context.hasChanges {
                do {
                    try self.performSaveContext(in: context)
                    completion?()
                    CoreDataLogger.log("Объект был успешно записан в БД: ", toSave)
                } catch {
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
