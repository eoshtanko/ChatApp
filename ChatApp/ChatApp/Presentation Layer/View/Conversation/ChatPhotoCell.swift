//
//  ChatPhotoCell.swift
//  ChatApp
//
//  Created by Екатерина on 29.04.2022.
//

import UIKit

class ChatPhotoCell: UITableViewCell {
    
    static let identifier = String(describing: ChatPhotoCell.self)
    
    var downloadImageAction: ((String, ((UIImage) -> Void)?) -> Void)?
    
    private static var themeManager: ThemeManagerProtocol = ThemeManager(theme: .classic)
    static var currentTheme: Theme = .classic {
        didSet {
            themeManager.theme = currentTheme
        }
    }
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    @IBOutlet weak var topSpace: NSLayoutConstraint!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var namelabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messageImageView.image = UIImage(named: "defaultImage")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        leadingConstraint = messageImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.messageLabelLeadingAndTrailingConstraint)
        trailingConstraint = messageImageView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                              constant: -Const.messageLabelLeadingAndTrailingConstraint)
    }
    
    func configureCell(_ chatMessage: Message) {
        if messageImageView.image == UIImage(named: "defaultImage") {
            configureContent(chatMessage)
        }
        configureSenderIdentifyingParameter(isOutcoming: chatMessage.senderId == CurrentUser.user.id)
        messageImageView.layer.cornerRadius = Const.cornerRadius
        setCurrentTheme()
    }
    
    private func configureSenderIdentifyingParameter(isOutcoming: Bool) {
        if isOutcoming {
            leadingConstraint?.isActive = false
            trailingConstraint?.isActive = true
        } else {
            trailingConstraint?.isActive = false
            leadingConstraint?.isActive = true
        }
        
        topSpace.constant = isOutcoming ? Const.topConstantWithoutName : Const.topConstantWithName
        
        namelabel.isHidden = isOutcoming
    }
    
    private func configureContent(_ chatMessage: Message) {
        downloadImageAction?(chatMessage.content, setImage)
        namelabel.text = chatMessage.senderName.isEmpty ? "No name" : chatMessage.senderName
    }
    
    private func setImage(image: UIImage) {
        messageImageView.image = image
    }
    
    static func setCurrentTheme(_ theme: Theme) {
        ChatPhotoCell.currentTheme = theme
    }
    
    private func setCurrentTheme() {
        backgroundColor = ChatPhotoCell.themeManager.themeSettings?.backgroundColor
        namelabel.textColor = ChatPhotoCell.themeManager.themeSettings?.secondaryTextColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private enum Const {
        static let messageLabelLeadingAndTrailingConstraint: CGFloat = 16
        static let cornerRadius: CGFloat = 12
        static let topConstantWithName: CGFloat = 30
        static let topConstantWithoutName: CGFloat = 0
    }
}
