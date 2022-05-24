//
//  ConversationsListViewController + UITextFieldDelegate.swift
//  ChatApp
//
//  Created by Екатерина on 14.04.2022.
//

import UIKit

extension ConversationsListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
