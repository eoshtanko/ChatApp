//
//  ConversationViewController + SendMessageMethods.swift
//  ChatApp
//
//  Created by Екатерина on 14.04.2022.
//

import UIKit

// Настройка view для ввода сообщения.
extension ConversationViewController {
    
    override var inputAccessoryView: UIView? {
        if entreMessageBar == nil {
            
            entreMessageBar = Bundle.main.loadNibNamed("EntryMessageView", owner: self, options: nil)?.first as? EntryMessageView
            
            entreMessageBar?.setCurrentTheme(currentTheme)
            entreMessageBar?.setSendMessageAction { [weak self] message in
                guard let self = self else { return }
                
                //                guard networkManager.isInternetConnected else {
                //                    self.showFailToSendMessageAlert()
                //                    return
                //                }
                
                self.sendMessage(message: message)
            }
        }
        
        return entreMessageBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var canResignFirstResponder: Bool {
        return true
    }
    
    private func sendMessage(message: String) {
        let newMessage = Message(content: message, senderId: CurrentUser.user.id, senderName: CurrentUser.user.name ?? "No name", created: Date())
        reference.addDocument(data: newMessage.toDict) { [weak self] error in
            if error != nil {
                self?.showFailToSendMessageAlert()
                return
            }
            self?.entreMessageBar?.sendMessageButton.isEnabled = false
            self?.entreMessageBar?.textView.text = ""
        }
    }
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardDidShow(_ notification: NSNotification) {
        if entreMessageBar?.textView.isFirstResponder ?? false {
            guard let payload = KeyboardInfo(notification) else { return }
            hightOfKeyboard = payload.frameEnd?.size.height
        }
        scrollToBottom(animated: false)
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        scrollToBottom(animated: false)
    }
    
    private func showFailToSendMessageAlert() {
        let failureAlert = UIAlertController(title: "Ошибка",
                                             message: "Не удалось отправить сообщение.",
                                             preferredStyle: UIAlertController.Style.alert)
        failureAlert.addAction(UIAlertAction(title: "OK",
                                             style: UIAlertAction.Style.default))
        failureAlert.addAction(UIAlertAction(title: "Повторить",
                                             style: UIAlertAction.Style.cancel) {_ in
            self.entreMessageBar?.sendMessage()
        })
        present(failureAlert, animated: true, completion: nil)
    }
}
