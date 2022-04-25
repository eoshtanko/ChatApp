//
//  ConversationViewController.swift
//  ChatApp
//
//  Created by Екатерина on 07.03.2022.
//

import UIKit
import Firebase
import CoreData

class ConversationViewController: UIViewController {
    
    private var themeManager: ThemeManagerProtocol = ThemeManager(theme: .classic)
    var currentTheme: Theme = .classic {
        didSet {
            themeManager.theme = currentTheme
        }
    }
    
    var entreMessageBar: EnterMessageView?
    var conversationView: ConversationView? {
        view as? ConversationView
    }
    
    let coreDataStack: CoreDataServiceProtocol?
    lazy var fetchedResultsController: NSFetchedResultsController<DBMessage>? = {
        let controller = coreDataStack?.getNSFetchedResultsControllerForMessages(channelId: channel?.identifier)
        controller?.delegate = self
        do {
            try controller?.performFetch()
        } catch {
            Logger.log("Ошибка при попытке выполнить Fetch-запрос.", .failure)
        }
        return controller
    }()
    
    private let channel: Channel?
    private let dbChannelReference: CollectionReference
    lazy var reference: CollectionReference = {
        guard let channelIdentifier = channel?.identifier else { fatalError() }
        return dbChannelReference.document(channelIdentifier).collection("messages")
    }()
    
    init?(coreDataStack: CoreDataServiceProtocol, theme: Theme, channel: Channel?, dbChannelRef: CollectionReference) {
        self.coreDataStack = coreDataStack
        self.channel = channel
        self.dbChannelReference = dbChannelRef
        self.currentTheme = theme
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        view = ConversationView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerKeyboardNotifications()
        themeManager.theme = currentTheme
        configureSnapshotListener()
        configureTapGestureRecognizer()
        configureTableView()
        conversationView?.configureView(themeManager: themeManager, theme: currentTheme,
                                        navigationItem: navigationItem, title: channel?.name,
                                        navigationController: navigationController,
                                        entreMessageBar: entreMessageBar)
    }
    
    private func configureTableView() {
        conversationView?.tableView.dataSource = self
        conversationView?.tableView.delegate = self
        conversationView?.configureTableView()
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
            coreDataStack?.saveMessage(message: message, channel: channel, id: change.document.documentID)
        case .removed, .modified:
            return
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum Const {
        static let dataModelName = "Chat"
        static let heightOfHeader: CGFloat = 50
        static let numberOfSections = 1
    }
}
