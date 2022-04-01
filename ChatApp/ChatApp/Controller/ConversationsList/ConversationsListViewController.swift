//
//  ConversationsListViewController.swift
//  ChatApp
//
//  Created by Екатерина on 06.03.2022.
//

import UIKit
import Firebase

class ConversationsListViewController: UIViewController {
    
    lazy var db = Firestore.firestore()
    lazy var reference = db.collection("channels")
    
    var channels: [Channel] = []
    var filteredChannels: [Channel]!
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    let searchBar = UISearchBar()
    var isSearching = false
    
    var currentTheme: Theme = .classic
    
    var profileViewController: ProfileViewController!
    
    private var activityIndicator: UIActivityIndicatorView!
    
    private let GCDMemoryManagerForApplicationPreferences = GCDMemoryManagerInterface<ApplicationPreferences>()
    
    private let dayNavBarAppearance = UINavigationBarAppearance()
    private let nightNavBarAppearance = UINavigationBarAppearance()
    
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
                self.showFailToLoadChannelsAlert()
                return
            }
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
    }
    
    private func showFailToLoadChannelsAlert() {
        let failureAlert = UIAlertController(title: "Ошибка", message: "Не удалось загрузить каналы.", preferredStyle: UIAlertController.Style.alert)
        failureAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default))
        failureAlert.addAction(UIAlertAction(title: "Повторить", style: UIAlertAction.Style.cancel) {_ in
            self.configureSnapshotListener()
        })
        present(failureAlert, animated: true, completion: nil)
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
        loadUserViaGCDB()
    }
    
    private func loadUserViaGCDB() {
        loadWithMemoryManager(memoryManager: GCDMemoryManagerInterface<User>())
    }
    
    private func loadWithMemoryManager<M: MemoryManagerInterfaceProtocol>(memoryManager: M) {
        memoryManager.readDataFromMemory(fileName: FileNames.plistFileNameForProfileInfo) { [weak self] result in
            if let result = result as? Result<User, Error> {
                self?.handleLoadProfileFromMemoryRequestResult(result: result)
            }
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
        addNewChannelButton.addTarget(self, action: #selector(showAddNewChannelAlert), for: .touchUpInside)
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
    
    @objc private func showAddNewChannelAlert() {
        let alert = UIAlertController(title: "Создать новый канал", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Имя нового канала"
            textField.enablesReturnKeyAutomatically = true
        }
        alert.addAction(UIAlertAction(title: "Создать", style: .default, handler: { [weak alert] (_) in
            if let textFieldText = alert?.textFields?[0].text, !textFieldText.isEmpty {
                self.createNewChannel(name: textFieldText)
            } else {
                self.showEmptyNameAlert()
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
                self.showFailToCreateChannelAlert(name)
                return
            }
        }
    }
    
    private func showFailToCreateChannelAlert(_ name: String) {
        let failureAlert = UIAlertController(title: "Ошибка",
                                             message: "Не удалось создать канал \(name).",
                                             preferredStyle: UIAlertController.Style.alert)
        failureAlert.addAction(UIAlertAction(title: "OK",
                                             style: UIAlertAction.Style.default))
        failureAlert.addAction(UIAlertAction(title: "Повторить",
                                             style: UIAlertAction.Style.cancel) {_ in
            self.createNewChannel(name: name)
        })
        present(failureAlert, animated: true, completion: nil)
    }
    
    private func showEmptyNameAlert() {
        let failureAlert = UIAlertController(title: "Имя не должно быть пустым!",
                                             message: nil,
                                             preferredStyle: UIAlertController.Style.alert)
        failureAlert.addAction(UIAlertAction(title: "OK",
                                             style: UIAlertAction.Style.cancel) {_ in
            self.showAddNewChannelAlert()
        })
        present(failureAlert, animated: true, completion: nil)
    }
    
    private func saveThemeToMemory() {
        let preferences = ApplicationPreferences(themeId: currentTheme.rawValue)
        GCDMemoryManagerForApplicationPreferences.writeDataToMemory(
            fileName: FileNames.plistFileNameForPreferences,
            objectToWrite: preferences, completionOperation: nil)
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
    
    func setDayOrClassicTheme() {
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
        
        if let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView {
            glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
            glassIconView.tintColor = .gray
        }
        
        if let clearButton = textFieldInsideSearchBar?.value(forKey: "clearButton") as? UIButton {
            clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            clearButton.tintColor = .gray
        }
        UITextField.appearance().keyboardAppearance = UIKeyboardAppearance.light
    }
    
    // ДОЛГО ДОЛГО ДОЛГО пыталась избавиться от этих
    // варинингов, но нет... :.(
    private func setDayOrClassicThemeToNavBar() {
        UIApplication.shared.statusBarStyle = .darkContent
        navigationItem.standardAppearance = dayNavBarAppearance
        navigationItem.scrollEdgeAppearance = dayNavBarAppearance
    }
    
    func setNightTheme() {
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
        
        if let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView {
            glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
            glassIconView.tintColor = .black
        }
        if let clearButton = textFieldInsideSearchBar?.value(forKey: "clearButton") as? UIButton {
            clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            clearButton.tintColor = .black
        }
        UITextField.appearance().keyboardAppearance = UIKeyboardAppearance.dark
    }
    
    private func setNightThemeToNavBar() {
        UIApplication.shared.statusBarStyle = .lightContent
        navigationItem.standardAppearance = nightNavBarAppearance
        navigationItem.scrollEdgeAppearance = nightNavBarAppearance
    }
    
    enum Const {
        static let numberOfSections = 1
        static let hightOfCell: CGFloat = 100
        static let sizeOfProfileNavigationButton: CGFloat = 40
        static let sizeOfSettingsNavigationButton: CGFloat = 24.8
    }
}

enum FileNames {
    static let plistFileNameForProfileInfo = "ProfileInfo.plist"
    static let plistFileNameForPreferences = "Preferences.plist"
}

extension ConversationsListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
