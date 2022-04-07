//
//  ConversationViewController.swift
//  ChatApp
//
//  Created by Екатерина on 07.03.2022.
//

import UIKit
import Firebase

class ConversationViewController: UITableViewController {
    
    let coreDataStack = NewCoreDataService(dataModelName: Const.dataModelName)
    // let coreDataStack = OldCoreDataService(dataModelName: Const.dataModelName)
    
    private var chatMessages: [Message] = []
    
    //    private let networkManager = NetworkManager()
    private let channel: Channel!
    private let dbChannelReference: CollectionReference
    private lazy var reference: CollectionReference = {
        guard let channelIdentifier = channel?.identifier else { fatalError() }
        return dbChannelReference.document(channelIdentifier).collection("messages")
    }()

    private var entreMessageBar: EntryMessageView?
    private var shouldScrollToBottom: Bool = true
    private var hightOfKeyboard: CGFloat?
    
    private var currentTheme: Theme = .classic
    
    private let nightNavBarAppearance = UINavigationBarAppearance()
    private let dayNavBarAppearance = UINavigationBarAppearance()
    
    init?(theme: Theme, channel: Channel?, dbChannelRef: CollectionReference) {
        currentTheme = theme
        self.channel = channel
        self.dbChannelReference = dbChannelRef
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        configureSnapshotListener()
        configureAppearances()
        registerKeyboardNotifications()
        configureTapGestureRecognizer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if shouldScrollToBottom {
            shouldScrollToBottom = false
            scrollToBottom(animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCurrentTheme()
    }
    
    private func fetchMessagesFromCash() {
        DispatchQueue.main.async {
            self.chatMessages = self.coreDataStack.readMessagesFromDB(channel: self.channel)
            self.tableView.reloadData()
        }
    }
    
    private func configureSnapshotListener() {
//        guard networkManager.isInternetConnected else {
//            self.showFailToLoadMessagesAlert()
//            return
//        }
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
        case .added, .modified:
            coreDataStack.saveMessage(message: message, channel: channel) { [weak self] in
                self?.fetchMessagesFromCash()
            }
        case .removed:
            CoreDataLogger.log("Кто-то что-то удалил, но мы об этом не узнаем, так как удаление реализовывать нас не просили :)", .success)
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
        tableView.estimatedRowHeight = Const.estimatedRowHeight
    }
    
    private func scrollToBottom(animated: Bool) {
        view.layoutIfNeeded()
        let bottomOffset = entreMessageBar?.textView.isFirstResponder ?? false ? bottomOffsetWithKeyboard() : bottomOffsetWithoutKeyboard()
        
        if isScrollingNecessary() {
            tableView.setContentOffset(bottomOffset, animated: false)
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
    
    private enum Const {
        static let dataModelName = "Chat"
        static let estimatedRowHeight: CGFloat = 60
        static let heightOfHeader: CGFloat = 50
        static let empiricalValue: CGFloat = 70
    }
}

// Все, что касается UITableView Delegate
extension ConversationViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Const.heightOfHeader
    }
}

// Все, что касается UITableView DataSource
extension ConversationViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatMessageCell.identifier,
            for: indexPath)
        guard let messageCell = cell as? ChatMessageCell else {
            return cell
        }
        let message = chatMessages[indexPath.row]
        messageCell.configureCell(message)
        return messageCell
    }
}

// Настройка view для ввода сообщения.
extension ConversationViewController {
    
    override var inputAccessoryView: UIView? {
        if entreMessageBar == nil {
            
            entreMessageBar = Bundle.main.loadNibNamed("EntryMessageView", owner: self, options: nil)?.first as? EntryMessageView
            
            entreMessageBar?.setCurrentTheme(currentTheme)
            entreMessageBar?.setSendMessageAction { [weak self] message in
                guard let self = self else { return }
                
//                guard networkManager.isInternetConnected else {
//                    self.showFailToSendMessageAlert()
//                    return
//                }
                
                self.sendMessage(message: message)
            }
        }
        
        return entreMessageBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var canResignFirstResponder: Bool {
        return true
    }
    
    private func sendMessage(message: String) {
        let newMessage = Message(content: message, senderId: CurrentUser.user.id, senderName: CurrentUser.user.name ?? "No name", created: Date())

        reference.addDocument(data: newMessage.toDict) { [weak self] error in
            guard let self = self else { return }
            if error != nil {
                self.showFailToSendMessageAlert()
                return
            }
            self.entreMessageBar?.sendMessageButton.isEnabled = false
            self.entreMessageBar?.textView.text = ""
        }
    }
    
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardDidShow(_ notification: NSNotification) {
        if entreMessageBar?.textView.isFirstResponder ?? false {
            guard let payload = KeyboardInfo(notification) else { return }
            hightOfKeyboard = payload.frameEnd?.size.height
        }
        scrollToBottom(animated: false)
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        scrollToBottom(animated: false)
    }
    
    private func showFailToSendMessageAlert() {
        let failureAlert = UIAlertController(title: "Ошибка",
                                             message: "Не удалось отправить сообщение.",
                                             preferredStyle: UIAlertController.Style.alert)
        failureAlert.addAction(UIAlertAction(title: "OK",
                                             style: UIAlertAction.Style.default))
        failureAlert.addAction(UIAlertAction(title: "Повторить",
                                             style: UIAlertAction.Style.cancel) {_ in
            self.entreMessageBar?.sendMessage()
        })
        present(failureAlert, animated: true, completion: nil)
    }
}

struct KeyboardInfo {
    var frameBegin: CGRect?
    var frameEnd: CGRect?
}

extension KeyboardInfo {
    init?(_ notification: NSNotification) {
        guard notification.name == UIResponder.keyboardWillShowNotification ||
                notification.name == UIResponder.keyboardWillChangeFrameNotification else { return nil }
        if let userInfo = notification.userInfo {
            frameBegin = userInfo[UIWindow.keyboardFrameBeginUserInfoKey] as? CGRect
            frameEnd = userInfo[UIWindow.keyboardFrameEndUserInfoKey] as? CGRect
        }
    }
}
