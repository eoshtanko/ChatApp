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
            
            entreMessageBar = Bundle.main.loadNibNamed("EnterMessageView", owner: self, options: nil)?.first as? EnterMessageView
            
            entreMessageBar?.setCurrentTheme(currentTheme)
            entreMessageBar?.setSendMessageAction { [weak self] message in
                self?.sendMessage(message: message)
            }
            entreMessageBar?.setSendPhotoAction { [weak self] in
                self?.sendPhoto()
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
        self.firebaseMessagesService?.sendMessage(message: newMessage, failAction: showFailToSendMessageAlert, successAction: resetData)
    }
    
    private func sendPhoto() {
        let photoSelectionViewController = PhotoSelectionViewController(choosePhotoAction: self.sendPhoto)
        photoSelectionViewController.setCurrentTheme(currentTheme)
        self.present(photoSelectionViewController, animated: true)
    }
    
    private func sendPhoto(_ urlString: String) {
        sendMessage(message: urlString)
    }
    
    private func resetData() {
        entreMessageBar?.resetData()
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
            conversationView?.hightOfKeyboard = payload.frameEnd?.size.height
        }
        conversationView?.scrollToBottom(animated: false, entreMessageBar: entreMessageBar)
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        conversationView?.scrollToBottom(animated: false, entreMessageBar: entreMessageBar)
    }
    
    func configureTapGestureRecognizer() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        entreMessageBar?.textView.resignFirstResponder()
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
