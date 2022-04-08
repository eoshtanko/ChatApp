//
//  NSManagedObject + Extension.swift
//  ChatApp
//
//  Created by Екатерина on 07.04.2022.
//

import CoreData

public extension NSManagedObject {

    convenience init?(usedContext: NSManagedObjectContext) {
        let name = String(describing: type(of: self))
        guard let entity = NSEntityDescription.entity(forEntityName: name, in: usedContext) else {
            return nil
        }
        self.init(entity: entity, insertInto: usedContext)
    }
}
