//
//  ConversationViewController.swift
//  ChatApp
//
//  Created by Екатерина on 07.03.2022.
//

import UIKit
import Firebase

class ConversationViewController: UIViewController {
    
    private let channel: Channel?
    
    let requestSender = RequestSender()
    
    var firebaseMessagesService: FirebaseMessagesServiceProtocol?
    
    let coreDataService = CoreDataServiceAssembly().coreDataServiceForMessages
    lazy var fetchedResultsController = coreDataService.fetchedResultsController(viewController: self, id: channel?.identifier)
    
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
    
    init?(theme: Theme, channel: Channel?, dbChannelRef: CollectionReference) {
        self.channel = channel
        self.firebaseMessagesService = FirebaseMessagesService(coreDataService: coreDataService, dbChannelReference: dbChannelRef, channel: channel)
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
        firebaseMessagesService?.configureSnapshotListener(failAction: showFailToLoadMessagesAlert) 
        configureTapGestureRecognizer()
        configureTableView()
        conversationView?.configureView(themeManager: themeManager, theme: currentTheme,
                                        navigationItem: navigationItem, title: channel?.name,
                                        navigationController: navigationController,
                                        entreMessageBar: entreMessageBar)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureTableView() {
        conversationView?.tableView.dataSource = self
        conversationView?.tableView.delegate = self
        conversationView?.configureTableView()
    }

    private func showFailToLoadMessagesAlert() {
        let failureAlert = UIAlertController(title: "Ошибка",
                                             message: "Не удалось загрузить сообщения.",
                                             preferredStyle: UIAlertController.Style.alert)
        failureAlert.addAction(UIAlertAction(title: "OK",
                                             style: UIAlertAction.Style.default))
        failureAlert.addAction(UIAlertAction(title: "Повторить",
                                             style: UIAlertAction.Style.cancel) { [weak self] _ in
            guard let self = self else { return }
            self.firebaseMessagesService?.configureSnapshotListener(failAction: self.showFailToLoadMessagesAlert)
        })
        present(failureAlert, animated: true, completion: nil)
    }
    
    func downloadImage(from url: String, competition: ((UIImage) -> Void)?) {
        let requestConfig = RequestsFactory.ImageRequests.getImage(urlString: url)
        requestSender.send(config: requestConfig) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    if let image = UIImage(data: data) {
                        competition?(image)
                    }
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func isDrawableImageMessage(_ mess: Message) -> Bool {
        guard let imagesApiNetProtocolAndHost = URLProvider.imagesApiNetProtocolAndHost else {
            return false
        }
        return mess.content.starts(with: imagesApiNetProtocolAndHost)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum Const {
        static let heightOfHeader: CGFloat = 50
        static let numberOfSections = 1
    }
}
