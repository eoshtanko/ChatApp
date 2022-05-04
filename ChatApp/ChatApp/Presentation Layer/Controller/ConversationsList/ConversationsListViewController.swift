//
//  ConversationsListViewController.swift
//  ChatApp
//
//  Created by Екатерина on 06.03.2022.
//

import UIKit

class ConversationsListViewController: UIViewController {
    
    let customTransition = CustomSlideTransitionViewController()
    
    let transition = CircleTransitionViewController()
    let interactiveTransition = CircleInteractiveTransition()
    
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
    
    private let userSavingService: UserSavingServiceProtocol = UserSavingService()
    
    let coreDataService = CoreDataServiceForChannels(dataModelName: Const.dataModelName)
    lazy var fetchedResultsController = coreDataService.fetchedResultsController(viewController: self)
    
    var firebaseChannelsService: FirebaseChannelsServiceProtocol?
    
    override func loadView() {
        view = ConversationsListView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCurrentUser()
        configureNetworking()
        configureNavigationBar()
        setInitialThemeToApp()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        conversationsListView?.configureNavigationTitle(navigationItem: navigationItem, navigationController: navigationController)
    }
    
    private func configureNetworking() {
        firebaseChannelsService = FirebaseChannelsService(coreDataService: coreDataService)
        firebaseChannelsService?.configureSnapshotListener(failAction: showFailToLoadChannelsAlert)
    }
    
    private func showFailToLoadChannelsAlert() {
        let failureAlert = UIAlertController(title: "Ошибка", message: "Не удалось загрузить каналы.", preferredStyle: UIAlertController.Style.alert)
        failureAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default))
        failureAlert.addAction(UIAlertAction(title: "Повторить", style: UIAlertAction.Style.cancel) { [weak self] _ in
            guard let self = self else { return }
            self.firebaseChannelsService?.configureSnapshotListener(failAction: self.showFailToLoadChannelsAlert)
        })
        present(failureAlert, animated: true, completion: nil)
    }
    
    func showFailToDeleteChannelAlert(id: String) {
        let failureAlert = UIAlertController(title: "Ошибка", message: "Не удалось удалить каналы.", preferredStyle: UIAlertController.Style.alert)
        failureAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default))
        failureAlert.addAction(UIAlertAction(title: "Повторить", style: UIAlertAction.Style.cancel) { [weak self] _ in
            guard let self = self else { return }
            self.firebaseChannelsService?.removeChannelFromFirebase(withID: id, failAction: self.showFailToDeleteChannelAlert)
        })
        present(failureAlert, animated: true, completion: nil)
    }
    
    private func configureTableView() {
        conversationsListView?.tableView.dataSource = self
        conversationsListView?.tableView.delegate = self
        conversationsListView?.configureTableView()
    }
    
    private func loadCurrentUser() {
        userSavingService.loadWithMemoryManager(complition: handleLoadProfileFromMemoryRequestResult)
    }
    
    private func handleLoadProfileFromMemoryRequestResult(result: Result<User, Error>?) {
        guard let result = result else {
            return
        }
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
        navigationController?.delegate = self
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
            navigationItem.leftBarButtonItems = [settingsButton, addButton]
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
                    self?.themeManager.writeThemeToMemory()
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
            textField.textColor = .black
            textField.enablesReturnKeyAutomatically = true
        }
        alert.addAction(UIAlertAction(title: "Создать", style: .default, handler: { [weak alert, weak self] (_) in
            guard let self = self else { return }
            if let textFieldText = alert?.textFields?[0].text, !textFieldText.isEmpty {
                self.firebaseChannelsService?.createNewChannel(name: textFieldText, failAction: self.showFailToCreateChannelAlert)
            } else {
                self.showEmptyNameAlert()
            }
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    private func showFailToCreateChannelAlert(_ name: String) {
        let failureAlert = UIAlertController(title: "Ошибка",
                                             message: "Не удалось создать канал \(name).",
                                             preferredStyle: UIAlertController.Style.alert)
        failureAlert.addAction(UIAlertAction(title: "OK",
                                             style: UIAlertAction.Style.default))
        failureAlert.addAction(UIAlertAction(title: "Повторить",
                                             style: UIAlertAction.Style.cancel) { [weak self] _ in
            guard let self = self else { return }
            self.firebaseChannelsService?.createNewChannel(name: name, failAction: self.showFailToCreateChannelAlert)
        })
        present(failureAlert, animated: true, completion: nil)
    }
    
    private func showEmptyNameAlert() {
        let failureAlert = UIAlertController(title: "Имя не должно быть пустым!",
                                             message: nil,
                                             preferredStyle: UIAlertController.Style.alert)
        failureAlert.addAction(UIAlertAction(title: "OK",
                                             style: UIAlertAction.Style.cancel) { [weak self] _ in
            self?.showAddNewChannelAlert()
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
            profileViewController.transitioningDelegate = self
            profileViewController.modalPresentationStyle = .custom
            profileViewController.interactiveTransition = interactiveTransition
            interactiveTransition.attach(to: profileViewController)
            
            profileViewController.setCurrentTheme(currentTheme)
            profileViewController.conversationsListViewController = self
            present(profileViewController, animated: true)
        }
    }
    
    enum Const {
        static let dataModelName = "Chat"
        static let numberOfSections = 1
        static let hightOfCell: CGFloat = 100
        static let circleTransitionOffset: CGFloat = 40
    }
}
