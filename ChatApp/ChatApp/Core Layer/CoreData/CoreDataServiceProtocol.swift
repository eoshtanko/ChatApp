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
