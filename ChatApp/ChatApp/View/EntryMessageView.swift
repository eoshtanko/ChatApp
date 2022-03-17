//
//  EntryMessageView.swift
//  ChatApp
//
//  Created by Екатерина on 10.03.2022.
//

import UIKit

class EntryMessageView: UIView {
    
    private var currentTheme: Theme = .classic
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var entryMessageView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setCurrentTheme()
        configureTextView()
        configureEntryMessageView()
    }
    
    internal func setCurrentTheme(_ theme: Theme) {
        currentTheme = theme
    }
    
    static func getEntyMessageViewHight() -> CGFloat {
        return Const.entyMessageViewHight
    }
    
    private func configureTextView() {
        textView.layer.borderWidth = Const.textViewBorderWidth
        textView.layer.cornerRadius = Const.textViewCornerRadius
    }
    
    private func configureEntryMessageView() {
        entryMessageView.frame.size = CGSize(width: UIScreen.main.bounds.size.width,
                                             height: Const.entyMessageViewHight)
    }
    
    private func setCurrentTheme() {
        switch currentTheme {
        case .classic, .day:
            setDayOrClassicTheme()
        case .night:
            setNightTheme()
        }
    }
    
    private func setDayOrClassicTheme() {
        textView.backgroundColor = .white
        entryMessageView.backgroundColor = UIColor(named: "BackgroundNavigationBarColor")
        entryMessageView.tintColor = .systemBlue
    }
    
    private func setNightTheme() {
        textView.backgroundColor = UIColor(named: "OutcomingMessageNightThemeColor")
        entryMessageView.backgroundColor = UIColor(named: "IncomingMessageNightThemeColor")
        entryMessageView.tintColor = .systemYellow
    }
    
    private enum Const {
        static let textViewBorderWidth = 0.1
        static let textViewCornerRadius: CGFloat = 16
        static let entyMessageViewHight: CGFloat = 74
    }
}
