//
//  ChatMessageCell.swift
//  ChatApp
//
//  Created by Екатерина on 09.03.2022.
//

import UIKit

class ChatMessageCell: UITableViewCell {
    
    static let identifier = String(describing: ChatMessageCell.self)
    
    private static var themeManager: ThemeManagerProtocol = ThemeManager(theme: .classic)
    static var currentTheme: Theme = .classic {
        didSet {
            themeManager.theme = currentTheme
        }
    }
    
    private let messageLabel = UILabel()
    private let bubbleBackgroundView = UIView()
    private let namelabel = UILabel()
    
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    
    private var messageLabelTopConstantWithName: NSLayoutConstraint?
    private var messageLabelTopConstantWithoutName: NSLayoutConstraint?
    
    private var incomingMessageUIColor: UIColor?
    private var outcomingMessageUIColor: UIColor?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.isUserInteractionEnabled = false
        addSubviews()
        configureBubbleBackgroundView()
        configureMessageLabel()
        configureConstraints()
    }
    
    private func addSubviews() {
        addSubview(bubbleBackgroundView)
        addSubview(messageLabel)
        addSubview(namelabel)
    }
    
    private func configureBubbleBackgroundView() {
        bubbleBackgroundView.layer.cornerRadius = Const.cornerRadius
        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureMessageLabel() {
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureCell(_ chatMessage: Message) {
        let message = getMessage(chatMessage)
        configureContent(message)
        setCurrentTheme()
        let isOutcoming = chatMessage.senderId == CurrentUser.user.id
        bubbleBackgroundView.backgroundColor = isOutcoming ? outcomingMessageUIColor : incomingMessageUIColor
        configureSenderIdentifyingParameter(isOutcoming: isOutcoming)
    }
    
    private func getMessage(_ chatMessage: Message) -> Message {
        if chatMessage.content.starts(with: "https://") && chatMessage.content.reversed().starts(with: ".jpg".reversed()) {
            let message = Message(content: getErrorApiMessage(chatMessage.content),
                                  senderId: chatMessage.senderId,
                                  senderName: chatMessage.senderName,
                                  created: chatMessage.created)
            return message
        }
        return chatMessage
    }
    
    private func getErrorApiMessage(_ str: String) -> String {
        return Const.errorApiMessage + str
    }
    
    private func configureSenderIdentifyingParameter(isOutcoming: Bool) {
        if isOutcoming {
            leadingConstraint?.isActive = false
            trailingConstraint?.isActive = true
            
            messageLabelTopConstantWithName?.isActive = false
            messageLabelTopConstantWithoutName?.isActive = true
        } else {
            trailingConstraint?.isActive = false
            leadingConstraint?.isActive = true
            
            messageLabelTopConstantWithoutName?.isActive = false
            messageLabelTopConstantWithName?.isActive = true
        }
        
        namelabel.isHidden = isOutcoming
    }
    
    private func configureContent(_ chatMessage: Message) {
        messageLabel.text = chatMessage.content
        namelabel.text = chatMessage.senderName.isEmpty ? "No name" : chatMessage.senderName
    }
    
    static func setCurrentTheme(_ theme: Theme) {
        ChatMessageCell.currentTheme = theme
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            namelabel.topAnchor.constraint(equalTo: topAnchor),
            
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Const.bottomConstant),
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: Const.messageLabelWidth),
            
            bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -Const.messageLabelBoarderConstraint),
            bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -Const.messageLabelBoarderConstraint),
            bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: Const.messageLabelBoarderConstraint),
            bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: Const.messageLabelBoarderConstraint)
        ])
        namelabel.frame.size = CGSize(width: Const.messageLabelWidth, height: Const.hightOfNameLabel)
        
        configureNameConstants()
        configureSenderIdentifyingConstants()
    }
    
    private func configureNameConstants() {
        messageLabelTopConstantWithName = messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: Const.topConstantWithName)
        messageLabelTopConstantWithoutName = messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: Const.topConstantWithoutName)
    }
    
    private func configureSenderIdentifyingConstants() {
        leadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.messageLabelLeadingAndTrailingConstraint)
        trailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.messageLabelLeadingAndTrailingConstraint)
    }
    
    private func setCurrentTheme() {
        backgroundColor = ChatMessageCell.themeManager.themeSettings?.backgroundColor
        namelabel.textColor = ChatMessageCell.themeManager.themeSettings?.secondaryTextColor
        messageLabel.textColor = ChatMessageCell.themeManager.themeSettings?.primaryTextColor
        incomingMessageUIColor = ChatMessageCell.themeManager.themeSettings?.incomingMessageColor
        outcomingMessageUIColor = ChatMessageCell.themeManager.themeSettings?.outcomingMessageColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private enum Const {
        static let messageLabelBoarderConstraint: CGFloat = 16
        static let messageLabelLeadingAndTrailingConstraint: CGFloat = 16 * 2
        static let messageLabelWidth: CGFloat = UIScreen.main.bounds.size.width * 3 / 4 - Const.messageLabelBoarderConstraint * 3
        static let cornerRadius: CGFloat = 12
        static let topConstantWithName: CGFloat = 46
        static let topConstantWithoutName: CGFloat = 16
        static let hightOfNameLabel: CGFloat = 21
        static let bottomConstant: CGFloat = -32
        static let errorApiMessage: String = "Api не поддерживается: "
    }
}
