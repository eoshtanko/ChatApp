//
//  ConversationsListViewController + UITableViewExtensions.swift
//  ChatApp
//
//  Created by Екатерина on 31.03.2022.
//

import Foundation
import UIKit

extension ConversationsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dbChannel = fetchedResultsController?.object(at: indexPath) else { return }
        do {
            let conversation = try coreDataService.parseDBChannelToChannel(dbChannel)
            
            self.navigationItem.title = ""
            let conversationViewController = ConversationViewController(theme: currentTheme,
                                                                        channel: conversation,
                                                                        dbChannelRef: reference)
            if let conversationViewController = conversationViewController {
                navigationController?.pushViewController(conversationViewController, animated: true)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        } catch {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Const.hightOfCell
    }
}

extension ConversationsListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Const.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else {
            return 0
        }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ConversationTableViewCell.identifier,
            for: indexPath)
        guard let conversationCell = cell as? ConversationTableViewCell else {
            return cell
        }
        guard let dbChannel = fetchedResultsController?.object(at: indexPath) else { return cell }
        let conversation = try? coreDataService.parseDBChannelToChannel(dbChannel)
        if let conversation = conversation {
            conversationCell.configureCell(conversation)
        }
        return conversationCell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let dbChannel = fetchedResultsController?.object(at: indexPath)
        let action = UIContextualAction(style: .destructive,
                                        title: "Delete") { [weak self] (_, _, completionHandler) in
            if let id = dbChannel?.identifier {
                self?.removeChannelFromFirebase(withID: id)
            }
            completionHandler(true)
        }
        action.backgroundColor = .systemRed
        action.image = UIImage(named: "trash")
        return UISwipeActionsConfiguration(actions: [action])
    }
}
