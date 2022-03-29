//
//  ConversationsListViewController.swift
//  ChatApp
//
//  Created by Екатерина on 06.03.2022.
//

import UIKit

class ConversationsListViewController: UIViewController {
    
    private let GCDMemoryManagerForApplicationPreferences = GCDMemoryManagerInterface<ApplicationPreferences>()
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let searchBar = UISearchBar()
    
    private var currentTheme: Theme = .classic
    
    private let dayNavBarAppearance = UINavigationBarAppearance()
    private let nightNavBarAppearance = UINavigationBarAppearance()
    
    private let onlineConversations = ConversationApi.getOnlineConversations()
    private let offlineConversations = ConversationApi.getOfflineConversations()
    private var filteredOnlineConversations: [Conversation]!
    private var filteredOfflineConversations: [Conversation]!
    
    private var profileViewController: ProfileViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCurrentUser()
        filteredOnlineConversations = onlineConversations
        filteredOfflineConversations = offlineConversations
        configureAppearances()
        configureTableView()
        configureNavigationBar()
        configureSearchBar()
        instatiateProfileViewController()
        setInitialThemeToApp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationTitle()
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
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func loadCurrentUser() {
        //loadUserViaGCDB()
        loadUserViaOperations()
    }
    
    private func loadUserViaGCDB() {
        loadWithMemoryManager(memoryManager: GCDMemoryManagerInterface<User>())
    }
    
    private func loadUserViaOperations() {
        loadWithMemoryManager(memoryManager: OperationMemoryManagerInterface<User>())
    }
    
    private func loadWithMemoryManager<M: MemoryManagerInterfaceProtocol>(memoryManager: M) {
        memoryManager.readDataFromMemory(fileName: FileNames.plistFileNameForProfileInfo) { [weak self] result in
            self?.handleLoadProfileFromMemoryRequestResult(result: result as! Result<User, Error>)
        }
    }
    
    private func handleLoadProfileFromMemoryRequestResult(result: Result<User, Error>) {
        DispatchQueue.main.async { [weak self] in
            switch result {
            case .success(let user):
                CurrentUser.user = user
                self?.configureRightNavigationButton()
            case .failure:
                return
            }
        }
    }
    
    private func configureNavigationBar() {
        configureNavigationTitle()
        configureNavigationButton()
    }
    
    private func configureNavigationTitle() {
        navigationItem.title = "Tinkoff Chat"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureNavigationButton() {
        configureLeftNavigationButton()
        configureRightNavigationButton()
    }
    
    private func configureLeftNavigationButton() {
        let settingsButton = UIButton(frame: CGRect(x: 0, y: 0, width: Const.sizeOfSettingsNavigationButton,
                                                    height: Const.sizeOfSettingsNavigationButton))
        setImageToSettingsNavigationButton(settingsButton)
        settingsButton.addTarget(self, action: #selector(goToSettings), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: settingsButton)
    }
    
    private func setImageToSettingsNavigationButton(_ settingsButton: UIButton) {
        settingsButton.setImage(UIImage(systemName: "gear"), for: .normal)
        settingsButton.imageView?.tintColor = UIColor(named: "GearButtonColor")
        settingsButton.contentHorizontalAlignment = .fill
        settingsButton.contentVerticalAlignment = .fill
    }
    
    @objc private func goToSettings() {
        let themesStoryboard = UIStoryboard(name: "Themes", bundle: nil)
        let themesViewController = themesStoryboard.instantiateViewController(identifier: "Themes", creator: { coder -> ThemesViewController? in
            ThemesViewController(coder: coder, themesPickerDelegate: self, theme: self.currentTheme) { [weak self] theme in
                if self?.currentTheme != theme {
                    self?.currentTheme = theme
                    self?.setCurrentTheme()
                    self?.saveThemeToMemory()
                }
            }
        })
        self.navigationItem.title = "Chat"
        navigationController?.pushViewController(themesViewController, animated: true)
    }
    
    private func saveThemeToMemory() {
        let preferences = ApplicationPreferences(themeId: currentTheme.rawValue)
        GCDMemoryManagerForApplicationPreferences.writeDataToMemory(fileName: FileNames.plistFileNameForPreferences, objectToWrite: preferences, completionOperation: nil)
    }
    
    private func setInitialThemeToApp() {
        setCurrentTheme()
        GCDMemoryManagerForApplicationPreferences.readDataFromMemory(fileName: FileNames.plistFileNameForPreferences) { [weak self] result in
            self?.handleLoadPreferencesFromMemoryRequestResult(result: result)
        }
    }
    
    private func handleLoadPreferencesFromMemoryRequestResult(result: Result<ApplicationPreferences, Error>) {
        DispatchQueue.main.async { [weak self] in
            switch result {
            case .success(let preferences):
                self?.currentTheme = Theme(rawValue: preferences.themeId) ?? .classic
                self?.setCurrentTheme()
            case .failure:
                return
            }
        }
    }
    
    func configureRightNavigationButton() {
        let profileButton = UIButton(frame: CGRect(x: 0, y: 0, width: Const.sizeOfProfileNavigationButton,
                                                   height: Const.sizeOfProfileNavigationButton))
        setImageToProfileNavigationButton(profileButton)
        profileButton.addTarget(self, action: #selector(goToProfile), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
    }
    
    private func setImageToProfileNavigationButton(_ profileButton: UIButton) {
        if let imageData = CurrentUser.user.imageData, var image = UIImage(data: imageData) {
            image = image.resized(to: CGSize(width: Const.sizeOfProfileNavigationButton,
                                             height: Const.sizeOfProfileNavigationButton))
            profileButton.setImage(image, for: .normal)
        } else {
            setDefaultImage(profileButton)
        }
        configureImage(profileButton)
    }
    
    private func setDefaultImage(_ profileButton: UIButton) {
        profileButton.setImage(UIImage(systemName: "person.fill"), for: .normal)
        profileButton.imageView?.tintColor = UIColor(named: "DefaultImageColor")
        profileButton.backgroundColor = UIColor(named: "BackgroundImageColor")
    }
    
    private func configureImage(_ profileButton: UIButton) {
        profileButton.imageView?.layer.cornerRadius = profileButton.frame.size.width / 2
        profileButton.layer.cornerRadius = profileButton.frame.size.width / 2
        profileButton.contentHorizontalAlignment = .fill
        profileButton.contentVerticalAlignment = .fill
        profileButton.imageView?.contentMode = .scaleAspectFill
        profileButton.imageView?.clipsToBounds = true
    }
    
    private func instatiateProfileViewController() {
        let profileStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        profileViewController = profileStoryboard.instantiateViewController(withIdentifier: "Profile") as? ProfileViewController
    }
    
    @objc private func goToProfile() {
        profileViewController.conversationsListViewController = self
        present(profileViewController, animated: true)
    }
    
    private func configureAppearances() {
        configureDayNavBarAppearance()
        configureNightNavBarAppearance()
    }
    
    private func configureDayNavBarAppearance() {
        dayNavBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        dayNavBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        dayNavBarAppearance.backgroundColor = UIColor(named: "BackgroundNavigationBarColor")
    }
    
    private func configureNightNavBarAppearance() {
        nightNavBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        nightNavBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        nightNavBarAppearance.backgroundColor = .black
    }
    
    private func setDayOrClassicTheme() {
        tableView.backgroundColor = .white
        setDayOrClassicThemeToSearchBar()
        setDayOrClassicThemeToNavBar()
        tableView.reloadData()
    }
    
    private func setDayOrClassicThemeToSearchBar() {
        searchBar.barTintColor = .white
        searchBar.barStyle = .default
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = UIColor(named: "BackgroundImageColor")
        textFieldInsideSearchBar?.textColor = .black
        
        let glassIconView = textFieldInsideSearchBar?.leftView as! UIImageView
        glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
        glassIconView.tintColor = .gray
        
        let clearButton = textFieldInsideSearchBar?.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        clearButton.tintColor = .gray
        
        UITextField.appearance().keyboardAppearance = UIKeyboardAppearance.light
    }
    
    // ДОЛГО ДОЛГО ДОЛГО пыталась избавиться от этих
    // варинингов, но нет... :.(
    private func setDayOrClassicThemeToNavBar() {
        UIApplication.shared.statusBarStyle = .darkContent
        //self.setNeedsStatusBarAppearanceUpdate()
        navigationItem.standardAppearance = dayNavBarAppearance
        navigationItem.scrollEdgeAppearance = dayNavBarAppearance
    }
    
    private func setNightTheme() {
        tableView.backgroundColor = .black
        setNightThemeToSearchBar()
        setNightThemeToNavBar()
        tableView.reloadData()
    }
    
    private func setNightThemeToSearchBar() {
        searchBar.barTintColor = .black
        searchBar.barStyle = .black
        searchBar.tintColor = .black
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = .systemYellow
        textFieldInsideSearchBar?.textColor = .black
        
        let glassIconView = textFieldInsideSearchBar?.leftView as! UIImageView
        glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
        glassIconView.tintColor = .black
        
        let clearButton = textFieldInsideSearchBar?.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        clearButton.tintColor = .black
        
        UITextField.appearance().keyboardAppearance = UIKeyboardAppearance.dark
    }
    
    private func setNightThemeToNavBar() {
        UIApplication.shared.statusBarStyle = .lightContent
        //self.setNeedsStatusBarAppearanceUpdate()
        navigationItem.standardAppearance = nightNavBarAppearance
        navigationItem.scrollEdgeAppearance = nightNavBarAppearance
    }
    
    //    override var preferredStatusBarStyle: UIStatusBarStyle {
    //        return currentTheme == .night ? UIStatusBarStyle.lightContent : UIStatusBarStyle.darkContent
    //    }
    
    private enum Const {
        static let numberOfSections = 2
        static let hightOfCell: CGFloat = 100
        static let sizeOfProfileNavigationButton: CGFloat = 40
        static let sizeOfSettingsNavigationButton: CGFloat = 24.8
    }
}

protocol ThemesPickerDelegate: AnyObject {
    func selectTheme(_ theme: Theme)
}

extension ConversationsListViewController: ThemesPickerDelegate {
    
    func selectTheme(_ theme: Theme) {
        //        if currentTheme != theme {
        //            currentTheme = theme
        //            setCurrentTheme()
        //            memoryManager.saveThemeToMemory()
        //        }
    }
    
    private func setCurrentTheme() {
        ConversationTableViewCell.setCurrentTheme(currentTheme)
        profileViewController?.setCurrentTheme(currentTheme)
        switch currentTheme {
        case .classic, .day:
            setDayOrClassicTheme()
        case .night:
            setNightTheme()
        }
    }
}

enum FileNames {
    static let plistFileNameForProfileInfo = "ProfileInfo.plist"
    static let plistFileNameForPreferences = "Preferences.plist"
}

enum Theme: Int {
    case classic
    case day
    case night
}

extension ConversationsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = indexPath.section == 0 ? filteredOnlineConversations[indexPath.row] : filteredOfflineConversations[indexPath.row]
        setupConversationsBeforePushViewController(conversation)
        self.navigationItem.title = ""
        
        let conversationViewController = ConversationViewController(theme: currentTheme)
        if let conversationViewController = conversationViewController {
            conversationViewController.conversation = conversation
            navigationController?.pushViewController(conversationViewController, animated: true)
        }
        tableView.reloadRows(at: [indexPath], with: .none)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Const.hightOfCell
    }
    
    private func setupConversationsBeforePushViewController(_ conversation: Conversation) {
        conversation.hasUnreadMessages = false
        if (conversation.message != nil) {
            ConversationApi.messages[0] = ChatMessage(text: conversation.message, isIncoming: true, date: conversation.date)
        }
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
            for: indexPath)
        guard let conversationCell = cell as? ConversationTableViewCell else {
            return cell
        }
        let conversation = indexPath.section == 0 ? filteredOnlineConversations[indexPath.row] : filteredOfflineConversations[indexPath.row]
        conversationCell.configureCell(conversation)
        return conversationCell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Online" : "History"
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

extension UIImage {
    
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
