//
//  ProfileViewController + UITextExtensions.swift
//  ChatApp
//
//  Created by Екатерина on 31.03.2022.
//

import Foundation
import UIKit

extension ProfileViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        if range.length + range.location > currentCharacterCount {
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= Const.maxNumOfCharsInName
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension ProfileViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        infoDidChanged = textView.text != initialInfo
        setEnableStatusToSaveButtons()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            profileView?.setEmptyStateToInfoLabel(themeManager)
        }
    }
}
