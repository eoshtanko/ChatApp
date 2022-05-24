//
//  EntryMessageView.swift
//  ChatApp
//
//  Created by Екатерина on 10.03.2022.
//

import UIKit

class EnterMessageView: UIView {
    
    private var themeManager: ThemeManagerProtocol = ThemeManager(theme: .classic)
    var currentTheme: Theme = .classic {
        didSet {
            themeManager.theme = currentTheme
            setCurrentTheme()
        }
    }
    
    private var sendMessageAction: ((String) -> Void)?
    private var sendPhotoAction: (() -> Void)?
    
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var enterMessageView: UIView!
    @IBOutlet weak var textViewHightConstraint: NSLayoutConstraint!
    
    @IBAction func sendMessage(_ sender: Any) {
        sendMessage()
    }
    
    @IBAction func sendPhoto(_ sender: Any) {
        sendPhotoAction?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureTextView()
        sendMessageButton.isEnabled = !textView.text.isEmpty
    }
    
    override var intrinsicContentSize: CGSize {
        return textViewContentSize()
    }
    
    func setCurrentTheme(_ theme: Theme?) {
        if let theme = theme {
            currentTheme = theme
        }
    }
    
    func setSendMessageAction(_ action: ((String) -> Void)?) {
        sendMessageAction = action
    }
    
    func setSendPhotoAction(_ action: (() -> Void)?) {
        sendPhotoAction = action
    }
    
    func resetData() {
        sendMessageButton.isEnabled = false
        textView.text = ""
    }
    
    func sendMessage() {
        if !textView.text.isEmpty {
            sendMessageAction?(textView.text)
        }
    }
    
    private func textViewContentSize() -> CGSize {
        let size = CGSize(width: textView.bounds.width,
                          height: CGFloat.greatestFiniteMagnitude)
        
        let textSize = textView.sizeThatFits(size)
        return CGSize(width: bounds.width, height: textSize.height)
    }
    
    private func configureTextView() {
        textView.delegate = self
        textView.layer.borderWidth = Const.textViewBorderWidth
        textView.layer.cornerRadius = Const.textViewCornerRadius
    }
    
    private func setCurrentTheme() {
        textView.backgroundColor = themeManager.themeSettings?.enterMessageTextViewBackgroundColor
        textView.textColor = themeManager.themeSettings?.primaryTextColor
        if let appearance = themeManager.themeSettings?.keyboardAppearance {
        textView.keyboardAppearance = appearance
        }
        backgroundColor = themeManager.themeSettings?.enterMessageViewBackgroundColor
        enterMessageView.tintColor = themeManager.themeSettings?.sendMessageButtonColor
    }
    
    private enum Const {
        static let textViewBorderWidth = 0.1
        static let textViewCornerRadius: CGFloat = 10
        static let textViewMaxHight: CGFloat = 36
    }
}

extension EnterMessageView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        sendMessageButton.isEnabled = !textView.text.isEmpty
        
        let contentHeight = textViewContentSize().height
        if textViewHightConstraint.constant != contentHeight && contentHeight < Const.textViewMaxHight {
            textViewHightConstraint.constant = contentHeight
            layoutIfNeeded()
        }
    }
}
