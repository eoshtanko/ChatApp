//
//  ConversationView.swift
//  ChatApp
//
//  Created by Екатерина on 25.04.2022.
//

import UIKit

class ConversationView: UITableView {
    
    var hightOfKeyboard: CGFloat?
    
    private lazy var bottomOffsetWithKeyboard: CGPoint = {
        return CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height + (hightOfKeyboard ?? 0))
    }()
    
    private func getBottomOffsetWithoutKeyboard(_ entreMessageBar: EnterMessageView?) -> CGPoint {
        return CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height + (entreMessageBar?.bounds.size.height ?? 0))
    }
    
    func configureView(navigationItem: UINavigationItem, title: String?, entreMessageBar: EnterMessageView?) {
        configureTableView()
        configureNavigationBar(navigationItem, title)
        scrollToBottom(animated: false, entreMessageBar: entreMessageBar)
    }
    
   private func configureNavigationBar(_ navigationItem: UINavigationItem, _ title: String?) {
        navigationItem.title = title
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func configureTableView() {
        self.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.identifier)
        self.separatorStyle = .none
        self.rowHeight = UITableView.automaticDimension
        self.addTopBounceAreaView()
    }
    
    func scrollToBottom(animated: Bool, entreMessageBar: EnterMessageView?) {
        self.layoutIfNeeded()
        if isScrollingNecessary(entreMessageBar) {
            let bottomOffset = entreMessageBar?.textView.isFirstResponder ?? false ? bottomOffsetWithKeyboard : getBottomOffsetWithoutKeyboard(entreMessageBar)
            
            self.setContentOffset(bottomOffset, animated: animated)
        }
    }
    
    private func isScrollingNecessary(_ entreMessageBar: EnterMessageView?) -> Bool {
        let bottomOffset = entreMessageBar?.textView.isFirstResponder ?? false ? hightOfKeyboard : entreMessageBar?.bounds.size.height
        return self.contentSize.height > self.bounds.size.height - (bottomOffset ?? 0) - Const.empiricalValue
    }
    
    func setCurrentTheme(themeManager: ThemeManagerProtocol, theme: Theme, navigationController: UINavigationController?, navigationItem: UINavigationItem) {
        self.backgroundColor = themeManager.themeSettings?.backgroundColor
        navigationItem.standardAppearance = themeManager.themeSettings?.navigationBarAppearance
        navigationController?.navigationBar.tintColor = themeManager.themeSettings?.navigationBarButtonColor
        self.reloadData()
        ChatMessageCell.setCurrentTheme(theme)
    }
    
    func addTopBounceAreaView(color: UIColor = .white) {
         var frame = UIScreen.main.bounds
         frame.origin.y = -frame.size.height

         let view = UIView(frame: frame)
         view.backgroundColor = color

         self.addSubview(view)
     }
    
    enum Const {
        static let estimatedRowHeight: CGFloat = 60
        static let empiricalValue: CGFloat = 70
    }
}
