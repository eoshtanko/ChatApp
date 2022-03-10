//
//  EntryMessageView.swift
//  ChatApp
//
//  Created by Екатерина on 10.03.2022.
//

import UIKit

class EntryMessageView: UIView {
    
    static let entyMessageViewHight: CGFloat = Const.entyMessageViewHight
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var entryMessageView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureTextView()
        configureEntryMessageView()
    }
    
    private func configureTextView() {
        textView.layer.borderWidth = Const.textViewBorderWidth
        textView.layer.cornerRadius = Const.textViewCornerRadius
    }
    
    private func configureEntryMessageView() {
        entryMessageView.frame.size = CGSize(width: UIScreen.main.bounds.size.width,
                                             height: Const.entyMessageViewHight)
    }
    
    private enum Const {
        static let textViewBorderWidth = 0.1
        static let textViewCornerRadius: CGFloat = 16
        static let entyMessageViewHight: CGFloat = 74
    }
}
