//
//  ConversationsListViewController.swift
//  ChatApp
//
//  Created by Екатерина on 06.03.2022.
//

import UIKit

class ConversationsListViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let searchBar = UISearchBar()
    
    private let onlineConversations = ConversationApi.getOnlineConversations()
    private let offlineConversations = ConversationApi.getOfflineConversations()
    private var filteredOnlineConversations: [Conversation]!
    private var filteredOfflineConversations: [Conversation]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filteredOnlineConversations = onlineConversations
        filteredOfflineConversations = offlineConversations
        configureView()
        configureTableView()
        configureNavigationBar()
        configureSearchBar()
    }
    
    private func configureView() {
        view.backgroundColor = .white
    }
    
    private func configureTableView() {
        tableView.register(
            UINib(nibName: String(describing: ConversationTableViewCell.self), bundle: nil),
            forCellReuseIdentifier: ConversationTableViewCell.identifier
        )
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        configureTableViewAppearance()
    }
    
    private func configureTableViewAppearance() {
        tableView.backgroundColor = .white
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .white
        configureNavigationTitle()
        configureNavigationButton()
    }
    
    private func configureNavigationTitle() {
        navigationItem.title = "Tinkoff Chat"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .black
    }
    
    private func configureNavigationButton() {
        let profileButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        setImageToNavigationButton(profileButton)
        profileButton.addTarget(self, action: #selector(goToProfile), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
    }
    
    private func setImageToNavigationButton(_ profileButton: UIButton) {
        if (CurrentUser.user.image == nil) {
            profileButton.setImage(UIImage(systemName: "person.fill"), for: .normal)
            profileButton.imageView?.tintColor = UIColor(named: "DefaultImageColor")
            profileButton.backgroundColor = UIColor(named: "BackgroundImageColor")
        } else {
            profileButton.setImage(CurrentUser.user.image, for: .normal)
        }
        profileButton.imageView?.layer.cornerRadius = profileButton.frame.size.width / 2
        profileButton.layer.cornerRadius = profileButton.frame.size.width / 2
        profileButton.contentHorizontalAlignment = .fill
        profileButton.contentVerticalAlignment = .fill
        profileButton.imageView?.contentMode = .scaleAspectFill
        profileButton.imageView?.clipsToBounds = true
    }
    
    @objc private func goToProfile() {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let profileViewController = storyboard.instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
        profileViewController.conversationsListViewController = self
        present(profileViewController, animated: true)
    }
}

extension ConversationsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(ConversationViewController(), animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Const.hightOfCell
    }
}

extension ConversationsListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        Const.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return filteredOnlineConversations.count
        } else {
            return filteredOfflineConversations.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ConversationTableViewCell.identifier,
            for: indexPath
        )
        guard let conversationCell = cell as? ConversationTableViewCell else {
            return cell
        }
        let conversation = indexPath.section == 0 ? filteredOnlineConversations[indexPath.row] : filteredOfflineConversations[indexPath.row]
        conversationCell.configureCell(name: conversation.name,
                                       message: conversation.message,
                                       date: conversation.date,
                                       online: conversation.online,
                                       hasUnreadMessages: conversation.hasUnreadMessages,
                                       image: conversation.image)
        return conversationCell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Online" : "History"
    }
    
    private enum Const {
        static let numberOfSections = 2
        static let hightOfCell: CGFloat = 100
    }
}

// Подумала, будет плюсом :)
extension ConversationsListViewController: UISearchBarDelegate {
    
    private func configureSearchBar() {
        tableView.tableHeaderView = searchBar
        searchBar.delegate = self
        searchBar.sizeToFit()
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.enablesReturnKeyAutomatically = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredOnlineConversations = searchText.isEmpty ? onlineConversations : onlineConversations.filter {
            (item: Conversation) -> Bool in
            return item.name?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        filteredOfflineConversations = searchText.isEmpty ? offlineConversations : offlineConversations.filter {
            (item: Conversation) -> Bool in
            return item.name?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
}


extension ConversationsListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
