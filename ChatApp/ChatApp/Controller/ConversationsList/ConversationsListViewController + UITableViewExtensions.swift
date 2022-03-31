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
        let conversation = isSearching ? filteredChannels[indexPath.row] : channels[indexPath.row]
        self.navigationItem.title = ""
        
        let conversationViewController = ConversationViewController(theme: currentTheme, channel: conversation, dbChannelRef: reference)
        if let conversationViewController = conversationViewController {
            navigationController?.pushViewController(conversationViewController, animated: true)
        }
        tableView.reloadRows(at: [indexPath], with: .none)
        tableView.deselectRow(at: indexPath, animated: true)
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
        return isSearching ? filteredChannels.count : channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ConversationTableViewCell.identifier,
            for: indexPath)
        guard let conversationCell = cell as? ConversationTableViewCell else {
            return cell
        }
        let conversation = isSearching ? filteredChannels[indexPath.row] : channels[indexPath.row]
        conversationCell.configureCell(conversation)
        return conversationCell
    }
}
