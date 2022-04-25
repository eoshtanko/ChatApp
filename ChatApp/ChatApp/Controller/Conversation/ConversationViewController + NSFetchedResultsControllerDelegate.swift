//
//  ConversationViewController + NSFetchedResultsControllerDelegate.swift
//  ChatApp
//
//  Created by Екатерина on 14.04.2022.
//

import UIKit
import CoreData

// Понимаю ли я, что безобразие прописывать подобный почти идентичный код как в ConversationsListViewController,
// так и в ConversationViewController ?
// Понимаю.
// Я попробовала сделать протокол, что-то вроде NSFetchedResultsControllerDelegateVC и
// в extension-е реализовать дублирующиеся методы,
// но столкнулась с проблемой: @objс методы не могут находиться в реализациях протокола, только в классах.

extension ConversationViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Logger.logPresenceInMethod(methodName: #function, " в переписке")
        tableView.beginUpdates()
        conversationView?.scrollToBottom(animated: false, entreMessageBar: entreMessageBar)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Logger.logPresenceInMethod(methodName: #function, " в переписке")
        tableView.endUpdates()
        conversationView?.scrollToBottom(animated: false, entreMessageBar: entreMessageBar)
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
            
            tableView.insertRows(at: [newIndexPath], with: .bottom)
            
        case .delete:
            guard let indexPath = indexPath else { return }
            
            tableView.deleteRows(at: [indexPath], with: .left)
            
        case .move:
            guard let indexPath = indexPath,
                  let newIndexPath = newIndexPath else { return }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            
        case .update:
            guard let indexPath = indexPath else { return }
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
        @unknown default:
            return
        }
    }
}
