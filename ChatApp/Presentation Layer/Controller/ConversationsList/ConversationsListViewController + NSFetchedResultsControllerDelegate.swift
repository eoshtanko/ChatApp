//  
//  ConversationsListViewController + NSFetchedResultsControllerDelegate.swift
//  ChatApp
//
//  Created by Екатерина on 14.04.2022.
//

import UIKit
import CoreData

extension ConversationsListViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Logger.logPresenceInMethod(methodName: #function, "в списке с переписками.")
        conversationsListView?.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Logger.logPresenceInMethod(methodName: #function, "в списке с переписками.")
        conversationsListView?.tableView.endUpdates()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            
            conversationsListView?.tableView.insertRows(at: [newIndexPath], with: .bottom)
            
        case .delete:
            guard let indexPath = indexPath else { return }
            
            conversationsListView?.tableView.deleteRows(at: [indexPath], with: .left)
            
        case .move:
            guard let indexPath = indexPath,
                  let newIndexPath = newIndexPath else { return }
            
            conversationsListView?.tableView.deleteRows(at: [indexPath], with: .automatic)
            conversationsListView?.tableView.insertRows(at: [newIndexPath], with: .automatic)
            
        case .update:
            guard let indexPath = indexPath else { return }
            
            conversationsListView?.tableView.reloadRows(at: [indexPath], with: .automatic)
            
        @unknown default:
            return
        }
    }
}
