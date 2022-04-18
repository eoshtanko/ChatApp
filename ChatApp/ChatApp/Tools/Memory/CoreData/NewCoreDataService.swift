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
    
    lazy var viewContext: NSManagedObjectContext = {
        let context = container.viewContext
        context.mergePolicy = NSOverwriteMergePolicy
        return context
    }()
    
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
    
    func fetchDBChannelById(id: String) -> [DBChannel]? {
        let fetchRequest = DBChannel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", id)
        guard let dbChannel = try? viewContext.fetch(fetchRequest) else {
            CoreDataLogger.log("Не удалось корректно выполнить Channel-fetch-запрос.", .failure)
            return nil
        }
        return dbChannel
    }
    
    func performTaskOnMainQueueContextAndSave(_ block: @escaping (NSManagedObjectContext) -> Void) {
        viewContext.performAndWait {
            block(viewContext)
        }
        saveViewContext()
    }
    
    private func saveViewContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                CoreDataLogger.log("Изменение объекта в бд прошло успешно.", .success)
            } catch {
                CoreDataLogger.log("Не удалось сохранить изменения объектов в родительском хранилище контекста.", .failure)
            }
        }
    }
}
