//
//  ConversationView.swift
//  ChatApp
//
//  Created by Екатерина on 25.04.2022.
//

import UIKit

class ConversationView: UIView {
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    var hightOfKeyboard: CGFloat?
    
    private lazy var bottomOffsetWithKeyboard: CGPoint = {
        return CGPoint(x: 0, y: tableView.contentSize.height - self.bounds.size.height + (hightOfKeyboard ?? 0))
    }()
    
    private func getBottomOffsetWithoutKeyboard(_ entreMessageBar: EnterMessageView?) -> CGPoint {
        return CGPoint(x: 0, y: tableView.contentSize.height - self.bounds.size.height + (entreMessageBar?.bounds.size.height ?? 0))
    }
    
    func configureView(themeManager: ThemeManagerProtocol, theme: Theme,
                       navigationItem: UINavigationItem, title: String?,
                       navigationController: UINavigationController?,
                       entreMessageBar: EnterMessageView?) {
        configureTableView()
        configureNavigationBar(navigationItem, title)
        scrollToBottom(animated: false, entreMessageBar: entreMessageBar)
        setCurrentTheme(themeManager, theme, navigationController, navigationItem)
    }
    
   private func configureNavigationBar(_ navigationItem: UINavigationItem, _ title: String?) {
        navigationItem.title = title
        navigationItem.largeTitleDisplayMode = .never
    }
    
    func configureTableView() {
        self.addSubview(tableView)
        registerCell()
        configureTableViewAppearance()
        backgroundColor = .white
    }
    
    private func registerCell() {
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.identifier)
        tableView.register(
            UINib(nibName: String(describing: ChatPhotoCell.self), bundle: nil),
            forCellReuseIdentifier: ChatPhotoCell.identifier
        )
    }
    
    private func configureTableViewAppearance() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: self.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func scrollToBottom(animated: Bool, entreMessageBar: EnterMessageView?) {
        tableView.layoutIfNeeded()
        if isScrollingNecessary(entreMessageBar) {
            let bottomOffset = entreMessageBar?.textView.isFirstResponder ?? false ? bottomOffsetWithKeyboard : getBottomOffsetWithoutKeyboard(entreMessageBar)
            
            tableView.setContentOffset(bottomOffset, animated: animated)
        }
    }
    
    private func isScrollingNecessary(_ entreMessageBar: EnterMessageView?) -> Bool {
        let bottomOffset = entreMessageBar?.textView.isFirstResponder ?? false ? hightOfKeyboard : entreMessageBar?.bounds.size.height
        return tableView.contentSize.height > self.bounds.size.height - (bottomOffset ?? 0) - Const.empiricalValue
    }
    
    func setCurrentTheme(_ themeManager: ThemeManagerProtocol, _ theme: Theme,
                         _ navigationController: UINavigationController?,
                         _ navigationItem: UINavigationItem) {
        tableView.backgroundColor = themeManager.themeSettings?.backgroundColor
        self.backgroundColor = themeManager.themeSettings?.backgroundColor
        navigationItem.standardAppearance = themeManager.themeSettings?.navigationBarAppearance
        navigationController?.navigationBar.tintColor = themeManager.themeSettings?.navigationBarButtonColor
        tableView.reloadData()
        ChatMessageCell.setCurrentTheme(theme)
    }
    
    enum Const {
        static let estimatedRowHeight: CGFloat = 60
        static let empiricalValue: CGFloat = 70
    }
}
