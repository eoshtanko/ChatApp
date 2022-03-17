//
//  ChatMessageCell.swift
//  ChatApp
//
//  Created by Екатерина on 09.03.2022.
//

import UIKit

// Меня смутили эти правила:
// 1. Для входящих сообщений:
// Текст сообщения не должен заходить на последнюю четверть ширины ячейки.
// 2. Для исходящих сообщений:
// Текст сообщения не должен заходить на первую четверть ширины ячейки.
//
// Посоветовавшись со здравым смыслом под шириной ячейки я здесь поняла не
// ширину конкретного "messageBubble", а ширину row (ширина экрана)
class ChatMessageCell: UITableViewCell {
    
    static let identifier = String(describing: ConversationTableViewCell.self)
    
    private let messageLabel = UILabel()
    private let bubbleBackgroundView = UIView()
    
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    func configureCell(_ chatMessage: ChatMessage) {
        messageLabel.text = chatMessage.text
        
        bubbleBackgroundView.backgroundColor = chatMessage.isIncoming ?
        UIColor(named: "IncomingMessageColor") : UIColor(named: "OutcomingMessageColor")
        messageLabel.textColor = .black
        
        if chatMessage.isIncoming {
            trailingConstraint.isActive = false
            leadingConstraint.isActive = true
        } else {
            leadingConstraint.isActive = false
            trailingConstraint.isActive = true
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(bubbleBackgroundView)
        addSubview(messageLabel)
        
        messageLabel.numberOfLines = 0
        self.isUserInteractionEnabled = false
        bubbleBackgroundView.layer.cornerRadius = Const.cornerRadius
        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        configureConstraints()
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: Const.topConstant),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Const.bottomConstant),
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: Const.messageLabelWidth),
            
            bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -Const.messageLabelBoarderConstraint),
            bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -Const.messageLabelBoarderConstraint),
            bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: Const.messageLabelBoarderConstraint),
            bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: Const.messageLabelBoarderConstraint),
        ])
        
        leadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.messageLabelLeadingAndTrailingConstraint)
        trailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.messageLabelLeadingAndTrailingConstraint)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private enum Const {
        static let messageLabelBoarderConstraint: CGFloat = 16
        static let messageLabelLeadingAndTrailingConstraint: CGFloat = 16 * 2
        static let messageLabelWidth: CGFloat = UIScreen.main.bounds.size.width * 3/4 - Const.messageLabelBoarderConstraint * 3
        static let cornerRadius: CGFloat = 12
        static let topConstant: CGFloat = 16
        static let bottomConstant: CGFloat = -32
    }
}
