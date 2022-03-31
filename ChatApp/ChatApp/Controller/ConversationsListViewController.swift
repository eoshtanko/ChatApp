//
//  ConversationsListViewController.swift
//  ChatApp
//
//  Created by Екатерина on 06.03.2022.
//

import UIKit
import Firebase

class ConversationsListViewController: UIViewController {
    
    private let GCDMemoryManagerForApplicationPreferences = GCDMemoryManagerInterface<ApplicationPreferences>()
    
    private lazy var db = Firestore.firestore()
    private lazy var reference = db.collection("channels")
    
    private var channels: [Channel] = []
    private var filteredChannels: [Channel]!
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let searchBar = UISearchBar()
    private var isSearching = false
    
    private var currentTheme: Theme = .classic
    
    private let dayNavBarAppearance = UINavigationBarAppearance()
    private let nightNavBarAppearance = UINavigationBarAppearance()
    
    private var profileViewController: ProfileViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCurrentUser()
        configureAppearances()
        filteredChannels = channels
        configureTableView()
        configureSnapshotListener()
        configureNavigationBar()
        configureSearchBar()
        instatiateProfileViewController()
        setInitialThemeToApp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationTitle()
    }
    
    private func configureSnapshotListener() {
        reference.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            guard error == nil, let snapshot = snapshot else {
                // alert
                return
            }
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let channel = Channel(document: change.document) else {
            return
        }
        
        switch change.type {
        case .added:
            addChannelToTable(channel)
        case .modified:
            updateChannelInTable(channel)
        case .removed:
            removeChannelFromTable(channel)
        }
    }
    
    private func addChannelToTable(_ channel: Channel) {
        if channels.contains(channel) {
            return
        }
        
        channels.append(channel)
        channels.sort()
        
        if !isSearching {
            guard let index = channels.firstIndex(of: channel) else {
                return
            }
            tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    private func updateChannelInTable(_ channel: Channel) {
        guard let index = channels.firstIndex(of: channel) else {
            return
        }
        
        channels[index] = channel
        channels.sort()
        
        if !isSearching {
            tableView.reloadData()
        }
    }
    
    private func removeChannelFromTable(_ channel: Channel) {
        guard let index = channels.firstIndex(of: channel) else {
            return
        }
        
        channels.remove(at: index)
        if !isSearching {
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
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
        navigationItem.title = "Channels"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureNavigationButton() {
        configureLeftNavigationButtons()
        configureRightNavigationButton()
    }
    
    private func configureLeftNavigationButtons() {
        let settingsBarButtonItem = getSettingsBarButtonItem()
        let addNewChannelBarButtonItem = getAddNewChannelBarButtonItem()
        self.navigationItem.leftBarButtonItems = [settingsBarButtonItem, addNewChannelBarButtonItem]
    }
    
    private func getSettingsBarButtonItem() -> UIBarButtonItem {
        let settingsButton = UIButton(frame: CGRect(x: 0, y: 0, width: Const.sizeOfSettingsNavigationButton,
                                                    height: Const.sizeOfSettingsNavigationButton))
        setImageToSettingsNavigationButton(settingsButton, imageName: "gear")
        settingsButton.addTarget(self, action: #selector(goToSettings), for: .touchUpInside)
        return UIBarButtonItem(customView: settingsButton)
    }
    
    private func getAddNewChannelBarButtonItem() -> UIBarButtonItem {
        let addNewChannelButton = UIButton(frame: CGRect(x: 0, y: 0, width: Const.sizeOfSettingsNavigationButton,
                                                    height: Const.sizeOfSettingsNavigationButton))
        setImageToSettingsNavigationButton(addNewChannelButton, imageName: "plus")
        addNewChannelButton.addTarget(self, action: #selector(addNewChannel), for: .touchUpInside)
        return UIBarButtonItem(customView: addNewChannelButton)
    }
    
    private func setImageToSettingsNavigationButton(_ settingsButton: UIButton, imageName: String) {
        settingsButton.setImage(UIImage(systemName: imageName), for: .normal)
        settingsButton.imageView?.tintColor = UIColor(named: "BarButtonColor")
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
    
    @objc private func addNewChannel() {
        let alert = UIAlertController(title: "Создать новый канал", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Имя нового канала"
            textField.enablesReturnKeyAutomatically = true
        }
        alert.addAction(UIAlertAction(title: "Создать", style: .default, handler: { [weak alert] (_) in
            if let textFieldText = alert?.textFields?[0].text, !textFieldText.isEmpty {
                self.createNewChannel(name: textFieldText)
            }
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func createNewChannel(name: String) {
        let channel = Channel(name: name)
        reference.addDocument(data: channel.toDict) { [weak self] error in
            guard let self = self else { return }
            if error != nil {
                self.showFailTiCreateChannelAlert(name)
              return
            }
        }
    }
    
    private func showFailTiCreateChannelAlert(_ name: String) {
        let failureAlert = UIAlertController(title: "Ошибка", message: "Не удалось создать канал.", preferredStyle: UIAlertController.Style.alert)
        failureAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default))
        failureAlert.addAction(UIAlertAction(title: "Повторить", style: UIAlertAction.Style.cancel) {_ in
            self.createNewChannel(name: name)
        })
        present(failureAlert, animated: true, completion: nil)
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
        navigationItem.standardAppearance = nightNavBarAppearance
        navigationItem.scrollEdgeAppearance = nightNavBarAppearance
    }
    
    private enum Const {
        static let numberOfSections = 1
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
        let conversation = isSearching ? filteredChannels[indexPath.row] : channels[indexPath.row]
        self.navigationItem.title = ""
        
        let conversationViewController = ConversationViewController(theme: currentTheme, channel: conversation, dbChannelRef: reference)
        if let conversationViewController = conversationViewController {
            navigationController?.pushViewController(conversationViewController, animated: true)
        }
        tableView.reloadRows(at: [indexPath], with: .none)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Const.hightOfCell
    }
}

extension ConversationsListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Const.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredChannels.count : channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ConversationTableViewCell.identifier,
            for: indexPath)
        guard let conversationCell = cell as? ConversationTableViewCell else {
            return cell
        }
        let conversation = isSearching ? filteredChannels[indexPath.row] : channels[indexPath.row]
        conversationCell.configureCell(conversation)
        return conversationCell
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
        isSearching = !searchText.isEmpty
        filteredChannels = searchText.isEmpty ? channels : channels.filter {
            (item: Channel) -> Bool in
            return item.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
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
