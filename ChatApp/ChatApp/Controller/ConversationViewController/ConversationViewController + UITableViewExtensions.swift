//
//  ConversationViewController + UITableViewExtensions.swift
//  ChatApp
//
//  Created by Екатерина on 14.04.2022.
//

import UIKit

// Все, что касается UITableView Delegate
extension ConversationViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Const.heightOfHeader
    }
}

// Все, что касается UITableView DataSource
extension ConversationViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else {
            return 0
        }
        return sections[section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatMessageCell.identifier,
            for: indexPath)
        guard let messageCell = cell as? ChatMessageCell else {
            return cell
        }
        let dbMessage = fetchedResultsController?.object(at: indexPath)
        let message = try? coreDataStack?.parseDBMessageToMessage(dbMessage)
        if let message = message {
            messageCell.configureCell(message)
        }
        return messageCell
    }
}
