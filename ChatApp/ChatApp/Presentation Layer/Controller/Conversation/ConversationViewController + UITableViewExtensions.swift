//
//  ConversationViewController + UITableViewExtensions.swift
//  ChatApp
//
//  Created by Екатерина on 14.04.2022.
//

import UIKit

extension ConversationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Const.heightOfHeader
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dbMessage = fetchedResultsController?.object(at: indexPath)
        let message = try? coreDataService.parseDBMessageToMessage(dbMessage)
        
        if let mess = message, let conversationView = conversationView, isDrawableImageMessage(mess) {
            return conversationView.getHightOfImageCell(mess)
        }
        return tableView.estimatedRowHeight
    }
}

extension ConversationViewController: UITableViewDataSource {
    
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
        let dbMessage = fetchedResultsController?.object(at: indexPath)
        let message = try? coreDataService.parseDBMessageToMessage(dbMessage)
        
        if let mess = message, isDrawableImageMessage(mess) {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ChatPhotoCell.identifier,
                for: indexPath)
            guard let messageCell = cell as? ChatPhotoCell else {
                return cell
            }
            messageCell.downloadImageAction = downloadImage
            if let message = message {
                messageCell.configureCell(message)
            }
            return messageCell
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ChatMessageCell.identifier,
                for: indexPath)
            guard let messageCell = cell as? ChatMessageCell else {
                return cell
            }
            if let message = message {
                messageCell.configureCell(message)
            }
            return messageCell
        }
    }
}
