//
//  ConversationsListView.swift
//  ChatApp
//
//  Created by Екатерина on 25.04.2022.
//

import UIKit

class ConversationsListView: UIView {
    
    private var activityIndicator: UIActivityIndicatorView?
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    var profileButton: UIButton?
    
    func configureTableView() {
        self.addSubview(tableView)
        registerCell()
        configureTableViewAppearance()
        backgroundColor = .white
    }
    
    private func registerCell() {
        tableView.register(
            UINib(nibName: String(describing: ConversationTableViewCell.self), bundle: nil),
            forCellReuseIdentifier: ConversationTableViewCell.identifier
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
    }
    
    func configureNavigationTitle(navigationItem: UINavigationItem, navigationController: UINavigationController?) {
        navigationItem.title = "Channels"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func getNavigationButton(name: String) -> UIButton {
        let settingsButton = UIButton(frame: CGRect(x: 0, y: 0, width: Const.sizeOfSettingsNavigationButton,
                                                    height: Const.sizeOfSettingsNavigationButton))
        setImageToSettingsNavigationButton(settingsButton, imageName: name)
        return settingsButton
    }
    
    func getProfileNavigationButton() -> UIButton? {
        profileButton = UIButton(frame: CGRect(x: 0, y: 0,
                                               width: Const.sizeOfProfileNavigationButton,
                                               height: Const.sizeOfProfileNavigationButton))
        
        setImageToProfileNavigationButton(profileButton)
        return profileButton
    }
    
    private func setImageToProfileNavigationButton(_ profileButton: UIButton?) {
        if let imageData = CurrentUser.user.imageData, var image = UIImage(data: imageData) {
            image = image.resized(to: CGSize(width: Const.sizeOfProfileNavigationButton,
                                             height: Const.sizeOfProfileNavigationButton))
            profileButton?.setImage(image, for: .normal)
        } else {
            setDefaultImage(profileButton)
        }
        configureImage(profileButton)
    }
    
    private func setImageToSettingsNavigationButton(_ settingsButton: UIButton, imageName: String) {
        settingsButton.setImage(UIImage(systemName: imageName), for: .normal)
        settingsButton.imageView?.tintColor = UIColor(named: "BarButtonColor")
        settingsButton.contentHorizontalAlignment = .fill
        settingsButton.contentVerticalAlignment = .fill
    }
    
    private func setDefaultImage(_ profileButton: UIButton?) {
        guard let profileButton = profileButton else { return }
        profileButton.accessibilityIdentifier = "goToProfileNavBarButton"
        profileButton.setImage(UIImage(systemName: "person.fill"), for: .normal)
        profileButton.imageView?.tintColor = UIColor(named: "DefaultImageColor")
        profileButton.backgroundColor = UIColor(named: "BackgroundImageColor")
    }
    
    private func configureImage(_ profileButton: UIButton?) {
        guard let profileButton = profileButton else { return }
        profileButton.imageView?.layer.cornerRadius = profileButton.frame.size.width / 2
        profileButton.layer.cornerRadius = profileButton.frame.size.width / 2
        profileButton.contentHorizontalAlignment = .fill
        profileButton.contentVerticalAlignment = .fill
        profileButton.imageView?.contentMode = .scaleAspectFill
        profileButton.imageView?.clipsToBounds = true
    }
    
    func setCurrentTheme(theme: Theme, themeManager: ThemeManagerProtocol, navigationItem: UINavigationItem) {
        ConversationTableViewCell.setCurrentTheme(theme)
        setThemeToConversationsList(themeManager, navigationItem: navigationItem)
    }
    
    private func setThemeToConversationsList(_ themeManager: ThemeManagerProtocol, navigationItem: UINavigationItem) {
        self.backgroundColor = themeManager.themeSettings?.backgroundColor
        tableView.backgroundColor = themeManager.themeSettings?.backgroundColor
        setThemeToNavBar(themeManager, navigationItem: navigationItem)
        tableView.reloadData()
    }
    
    private func setThemeToNavBar(_ themeManager: ThemeManagerProtocol, navigationItem: UINavigationItem) {
        navigationItem.standardAppearance = themeManager.themeSettings?.navigationBarAppearance
        navigationItem.scrollEdgeAppearance = themeManager.themeSettings?.navigationBarAppearance
    }
    
    enum Const {
        static let sizeOfProfileNavigationButton: CGFloat = 40
        static let sizeOfSettingsNavigationButton: CGFloat = 24.8
    }
}
