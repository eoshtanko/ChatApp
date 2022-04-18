//
//  ConversationViewController.swift
//  ChatApp
//
//  Created by Екатерина on 07.03.2022.
//

import UIKit
import Firebase
import CoreData

class ConversationViewController: UITableViewController {
    
    let coreDataStack: CoreDataServiceProtocol!
    lazy var fetchedResultsController: NSFetchedResultsController<DBMessage> = {
        let controller = coreDataStack.getNSFetchedResultsControllerForMessages(channelId: channel.identifier)
        controller.delegate = self
        do {
            try controller.performFetch()
        } catch {
            CoreDataLogger.log("Ошибка при попытке выполнить Fetch-запрос.", .failure)
        }
        return controller
    }()
    
    //    private let networkManager = NetworkManager()
    private let channel: Channel!
    private let dbChannelReference: CollectionReference
    lazy var reference: CollectionReference = {
        guard let channelIdentifier = channel?.identifier else { fatalError() }
        return dbChannelReference.document(channelIdentifier).collection("messages")
    }()
    
    var entreMessageBar: EntryMessageView?
    var shouldScrollToBottom: Bool = true
    var hightOfKeyboard: CGFloat?
    
    var currentTheme: Theme = .classic
    
    private let nightNavBarAppearance = UINavigationBarAppearance()
    private let dayNavBarAppearance = UINavigationBarAppearance()
    
    init?(coreDataStack: CoreDataServiceProtocol, theme: Theme, channel: Channel?, dbChannelRef: CollectionReference) {
        self.coreDataStack = coreDataStack
        currentTheme = theme
        self.channel = channel
        self.dbChannelReference = dbChannelRef
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNavigationBar()
        configureAppearances()
        registerKeyboardNotifications()
        configureTapGestureRecognizer()
        configureSnapshotListener()
        scrollToBottom(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCurrentTheme()
    }
    
    private func configureSnapshotListener() {
        reference.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            guard error == nil, let snapshot = snapshot else {
                self.showFailToLoadMessagesAlert()
                return
            }
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
    }
    
    private func showFailToLoadMessagesAlert() {
        let failureAlert = UIAlertController(title: "Ошибка",
                                             message: "Не удалось загрузить сообщения.",
                                             preferredStyle: UIAlertController.Style.alert)
        failureAlert.addAction(UIAlertAction(title: "OK",
                                             style: UIAlertAction.Style.default))
        failureAlert.addAction(UIAlertAction(title: "Повторить",
                                             style: UIAlertAction.Style.cancel) {_ in
            self.configureSnapshotListener()
        })
        present(failureAlert, animated: true, completion: nil)
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let message = Message(document: change.document) else {
            return
        }
        switch change.type {
        case .added:
            coreDataStack.saveMessage(message: message, channel: channel, id: change.document.documentID)
        case .removed, .modified:
            // Будем считать, что удалять/редактировать сообщения НИЗЯ
            return
        }
    }
    
    private func configureTapGestureRecognizer() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        entreMessageBar?.textView.resignFirstResponder()
    }
    
    private func configureNavigationBar() {
        navigationItem.title = channel?.name
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func configureTableView() {
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func scrollToBottom(animated: Bool) {
        view.layoutIfNeeded()
        if isScrollingNecessary() {
            let bottomOffset = entreMessageBar?.textView.isFirstResponder ?? false ? bottomOffsetWithKeyboard() : bottomOffsetWithoutKeyboard()
            
            tableView.setContentOffset(bottomOffset, animated: animated)
        }
    }
    
    private func isScrollingNecessary() -> Bool {
        let bottomOffset = entreMessageBar?.textView.isFirstResponder ?? false ? hightOfKeyboard : entreMessageBar?.bounds.size.height
        return tableView.contentSize.height > tableView.bounds.size.height - (bottomOffset ?? 0) - Const.empiricalValue
    }
    
    private func bottomOffsetWithKeyboard() -> CGPoint {
        return CGPoint(x: 0, y: tableView.contentSize.height - tableView.bounds.size.height + (hightOfKeyboard ?? 0))
    }
    
    private func bottomOffsetWithoutKeyboard() -> CGPoint {
        return CGPoint(x: 0, y: tableView.contentSize.height - tableView.bounds.size.height + (entreMessageBar?.bounds.size.height ?? 0))
    }
    
    private func configureAppearances() {
        configureNavBarAppearanceForNightTheme()
        configureNavBarAppearanceForDayOrClassicTheme()
    }
    
    private func configureNavBarAppearanceForNightTheme() {
        nightNavBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        nightNavBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        nightNavBarAppearance.backgroundColor = UIColor(named: "IncomingMessageNightThemeColor")
    }
    
    private func configureNavBarAppearanceForDayOrClassicTheme() {
        dayNavBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        dayNavBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        dayNavBarAppearance.backgroundColor = UIColor(named: "BackgroundNavigationBarColor")
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
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .systemBlue
        navigationItem.standardAppearance = dayNavBarAppearance
        ChatMessageCell.setCurrentTheme(currentTheme)
        tableView.reloadData()
    }
    
    private func setNightTheme() {
        tableView.backgroundColor = .black
        navigationController?.navigationBar.tintColor = .systemYellow
        navigationItem.standardAppearance = nightNavBarAppearance
        ChatMessageCell.setCurrentTheme(currentTheme)
        tableView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum Const {
        static let dataModelName = "Chat"
        static let estimatedRowHeight: CGFloat = 60
        static let heightOfHeader: CGFloat = 50
        static let empiricalValue: CGFloat = 70
    }
}
