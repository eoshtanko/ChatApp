//
//  ConversationTableViewCell.swift
//  ChatApp
//
//  Created by Екатерина on 06.03.2022.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: ConversationTableViewCell.self)
    
    private static var currentTheme: Theme = .classic
    private let formatter = DateFormatter()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var lastMessageDateLabel: UILabel!
    @IBOutlet weak var onlineSignImageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(
            top: Const.verticalInserts, left: Const.horizontalInserts,
            bottom: Const.verticalInserts, right: Const.horizontalInserts))
        contentView.layer.cornerRadius = Const.contentViewCornerRadius
        setCurrentTheme()
    }
    
    static func setCurrentTheme(_ theme: Theme) {
        ConversationTableViewCell.currentTheme = theme
    }
    
    func configureCell(_ conversation: Channel) {
        configureNameLabel(conversation.name)
        configureLastMessageDate(conversation.lastActivity)
        configureLastMessageLabel(conversation.lastMessage)
    }
    
    private func configureNameLabel(_ name: String?) {
        if name == nil {
            nameLabel.font = .italicSystemFont(ofSize: Const.textSize)
            nameLabel.text = "No Name"
        } else {
            nameLabel.font = .systemFont(ofSize: Const.textSize, weight: .semibold)
            nameLabel.text = name
        }
    }
    
    private func configureLastMessageDate(_ date: Date?) {
        guard let date = date else {
            lastMessageDateLabel.font = .italicSystemFont(ofSize: Const.textSize)
            lastMessageDateLabel.text = "No Date"
            return
        }
        lastMessageDateLabel.font = .systemFont(ofSize: Const.textSize)
        lastMessageDateLabel.text = fromDateToString(from: date)
    }
    
    private func fromDateToString(from date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "HH:mm a"
            return formatter.string(from: date)
        }
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "en_GB")
        formatter.doesRelativeDateFormatting = true
        return formatter.string(from: date)
    }
    
    private func configureLastMessageLabel(_ message: String?) {
        if message == nil {
            lastMessageLabel.text = "No messages yet"
            lastMessageLabel.font = .italicSystemFont(ofSize: Const.textSize)
        } else {
            lastMessageLabel.text = message
            lastMessageLabel.font = .systemFont(ofSize: Const.textSize)
        }
    }
    
    private func setCurrentTheme() {
        switch ConversationTableViewCell.currentTheme {
        case .classic, .day:
            setDayOrClassicTheme()
        case .night:
            setNightTheme()
        }
    }
    
    private func setDayOrClassicTheme() {
        backgroundColor = .white
        nameLabel.textColor = .black
        lastMessageLabel.textColor = .black
        lastMessageDateLabel.textColor = .black
    }
    
    private func setNightTheme() {
        backgroundColor = .black
        nameLabel.textColor = .white
        lastMessageLabel.textColor = .white
        lastMessageDateLabel.textColor = .white
    }
    
    private enum Const {
        static let textSize: CGFloat = 15
        static let verticalInserts: CGFloat = 15
        static let horizontalInserts: CGFloat = 10
        static let contentViewCornerRadius: CGFloat = 10
    }
}
