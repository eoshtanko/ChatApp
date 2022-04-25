//
//  ConversationsListViewController.swift
//  ChatApp
//
//  Created by Екатерина on 06.03.2022.
//

import UIKit
import Firebase
import CoreData

// Вынести алерты
class ConversationsListViewController: UIViewController {
    
    var conversationsListView: ConversationsListView? {
        view as? ConversationsListView
    }
    
    private var themeManager: ThemeManagerProtocol = ThemeManager(theme: .classic)
    var currentTheme: Theme = .classic {
        didSet {
            themeManager.theme = currentTheme
            conversationsListView?.setCurrentTheme(theme: currentTheme, themeManager: themeManager, navigationItem: navigationItem)
        }
    }
    
    let coreDataStack = NewCoreDataService(dataModelName: Const.dataModelName)
    // TODO подумать. Наверное, это можно убрать из этого контроллера
    lazy var fetchedResultsController: NSFetchedResultsController<DBChannel> = {
        let controller = coreDataStack.getNSFetchedResultsControllerForChannels()
        controller.delegate = self
        do {
            try controller.performFetch()
        } catch {
            Logger.log("Ошибка при попытке выполнить Fetch-запрос.", .failure)
        }
        return controller
    }()
    
    lazy var db = Firestore.firestore()
    lazy var reference = db.collection("channels")
    
    override func loadView() {
        view = ConversationsListView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCurrentUser()
        configureSnapshotListener()
        configureNavigationBar()
        setInitialThemeToApp()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        conversationsListView?.configureNavigationTitle(navigationItem: navigationItem, navigationController: navigationController)
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
        case .added, .modified:
            coreDataStack.saveChannel(channel: channel)
        case .removed:
            coreDataStack.deleteChannel(channel: channel)
        }
    }
    
    func removeChannelFromFirebase(withID id: String) {
        reference.document(id).delete { [weak self] err in
            if err != nil {
                self?.showFailToDeleteChannelAlert(id: id)
            }
        }
    }
    
    private func showFailToDeleteChannelAlert(id: String) {
        let failureAlert = UIAlertController(title: "Ошибка", message: "Не удалось удалить каналы.", preferredStyle: UIAlertController.Style.alert)
        failureAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default))
        failureAlert.addAction(UIAlertAction(title: "Повторить", style: UIAlertAction.Style.cancel) {_ in
            self.removeChannelFromFirebase(withID: id)
        })
        present(failureAlert, animated: true, completion: nil)
    }
    
    private func configureTableView() {
        conversationsListView?.tableView.dataSource = self
        conversationsListView?.tableView.delegate = self
        conversationsListView?.configureTableView()
    }
    
    private func loadCurrentUser() {
        loadWithMemoryManager(memoryManager: GCDMemoryManagerInterface<User>())
    }
    
    private func loadWithMemoryManager<M: MemoryManagerProtocol>(memoryManager: M) {
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
        conversationsListView?.configureNavigationTitle(navigationItem: navigationItem, navigationController: navigationController)
        configureNavigationButtons()
    }
    
    private func configureNavigationButtons() {
        configureLeftNavigationButtons()
        configureRightNavigationButton()
    }
    
    private func configureLeftNavigationButtons() {
        let settingsBarButtonItem = getSettingsBarButtonItem()
        let addNewChannelBarButtonItem = getAddNewChannelBarButtonItem()
        if let settingsButton = settingsBarButtonItem, let addButton = addNewChannelBarButtonItem {
            self.navigationItem.leftBarButtonItems = [settingsButton, addButton]
        }
    }
    
    private func getSettingsBarButtonItem() -> UIBarButtonItem? {
        let settingsButton = conversationsListView?.getNavigationButton(name: "gear")
        settingsButton?.addTarget(self, action: #selector(goToSettings), for: .touchUpInside)
        if let settingsButton = settingsButton {
            return UIBarButtonItem(customView: settingsButton)
        } else { return nil }
    }
    
    private func getAddNewChannelBarButtonItem() -> UIBarButtonItem? {
        let settingsButton = conversationsListView?.getNavigationButton(name: "plus")
        settingsButton?.addTarget(self, action: #selector(showAddNewChannelAlert), for: .touchUpInside)
        if let settingsButton = settingsButton {
            return UIBarButtonItem(customView: settingsButton)
        } else { return nil }
    }
    
    @objc private func goToSettings() {
        let themesStoryboard = UIStoryboard(name: "Themes", bundle: nil)
        let themesViewController = themesStoryboard.instantiateViewController(identifier: "Themes", creator: { coder -> ThemesViewController? in
            ThemesViewController(coder: coder, theme: self.currentTheme) { [weak self] theme in
                if self?.currentTheme != theme {
                    self?.themeManager.theme = theme
                    self?.currentTheme = theme
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
    
    private func setInitialThemeToApp() {
        conversationsListView?.setCurrentTheme(theme: currentTheme, themeManager: themeManager, navigationItem: navigationItem)
        themeManager.readThemeFromMemory { [weak self] result in
            self?.handleLoadPreferencesFromMemoryRequestResult(result: result)
        }
    }
    
    private func handleLoadPreferencesFromMemoryRequestResult(result: Result<ApplicationPreferences, Error>) {
        DispatchQueue.main.async { [weak self] in
            switch result {
            case .success(let preferences):
                self?.currentTheme = Theme(rawValue: preferences.themeId) ?? .classic
            case .failure:
                return
            }
        }
    }
    
    func configureRightNavigationButton() {
        if let profileButton = conversationsListView?.getProfileNavigationButton() {
            profileButton.addTarget(self, action: #selector(goToProfile), for: .touchUpInside)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
        }
    }
    
    @objc private func goToProfile() {
        let profileStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let profileViewController = profileStoryboard.instantiateViewController(withIdentifier: "Profile") as? ProfileViewController
        if let profileViewController = profileViewController {
            profileViewController.setCurrentTheme(currentTheme)
            profileViewController.conversationsListViewController = self
            present(profileViewController, animated: true)
        }
    }
    
    enum Const {
        static let dataModelName = "Chat"
        static let numberOfSections = 1
        static let hightOfCell: CGFloat = 100
    }
}
