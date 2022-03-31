//
//  ConversationViewController.swift
//  ChatApp
//
//  Created by Екатерина on 07.03.2022.
//

import UIKit
import Firebase

class ConversationViewController: UITableViewController {
    
    private var chatMessages: [Message] = []
    
    private let channel: Channel?
    private let dbChannelReference: CollectionReference
    private lazy var reference: CollectionReference = {
        guard let channelIdentifier = channel?.identifier else { fatalError() }
        return dbChannelReference.document(channelIdentifier).collection("messages")
    }()
    
    private var entreMessageBar: EntryMessageView?
    private var shouldScrollToBottom: Bool = true
    
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
        guard let message = Message(document: change.document) else {
            return
        }
        switch change.type {
        case .added:
            addMessageToTable(message)
        case .modified:
            updateMessageInTable(message)
        case .removed:
            removeMessageFromTable(message)
        }
    }
    
    private func addMessageToTable(_ message: Message) {
        if chatMessages.contains(message) {
            return
        }
        
        chatMessages.append(message)
        chatMessages.sort()
        
        guard let index = chatMessages.firstIndex(of: message) else {
            return
        }
        tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        scrollToBottom(animated: false)
    }
    
    private func updateMessageInTable(_ message: Message) {
        guard let index = chatMessages.firstIndex(of: message) else {
            return
        }
        
        chatMessages[index] = message
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func removeMessageFromTable(_ message: Message) {
        guard let index = chatMessages.firstIndex(of: message) else {
            return
        }
        
        chatMessages.remove(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
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
        tableView.setContentOffset(bottomOffset(), animated: false)
    }
    
    private func bottomOffset() -> CGPoint {
        return CGPoint(x: 0, y: max(-tableView.contentInset.top, tableView.contentSize.height - (tableView.bounds.size.height - tableView.contentInset.bottom)))
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
        static let estimatedRowHeight: CGFloat = 60
        static let heightOfHeader: CGFloat = 50
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
                let newMessage = Message(content: message, senderId: CurrentUser.user.id, senderName: CurrentUser.user.name ?? "No name", created: Date())
                self?.reference.addDocument(data: newMessage.toDict) { [weak self] error in
                    guard let self = self else { return }
                    if error != nil {
                        return
                    }
                    self.entreMessageBar?.textView.text = ""
                }
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
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    @objc func keyboardWillShow(_ notification: NSNotification) {
        adjustContentForKeyboard(shown: true, notification: notification)
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        adjustContentForKeyboard(shown: false, notification: notification)
    }
    
    func adjustContentForKeyboard(shown: Bool, notification: NSNotification) {
        guard let payload = KeyboardInfo(notification) else { return }
        
        let keyboardHeight = shown ? payload.frameEnd.size.height : entreMessageBar?.bounds.size.height ?? 0
        if tableView.contentInset.bottom == keyboardHeight {
            return
        }
        
        let distanceFromBottom = bottomOffset().y - tableView.contentOffset.y
        
        var insets = tableView.contentInset
        insets.bottom = keyboardHeight
        
        UIView.animate(withDuration: 0.01, delay: 0, options: .curveEaseIn, animations: {
            
            self.tableView.contentInset = insets
            self.tableView.scrollIndicatorInsets = insets
            
            if distanceFromBottom < 10 {
                self.tableView.contentOffset = self.bottomOffset()
            }
        }, completion: nil)
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
