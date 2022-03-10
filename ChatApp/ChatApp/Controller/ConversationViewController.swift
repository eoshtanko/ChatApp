//
//  ConversationViewController.swift
//  ChatApp
//
//  Created by Екатерина on 07.03.2022.
//

import UIKit

class ConversationViewController: UITableViewController {
    
    var conversation: Conversation?
    private var chatMessages = [[ChatMessage]]()
    private var entreMessageBar: UIView?
    private var shouldScrollToBottom: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        assembleGroupedMessages()
        configureTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToBottom()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        becomeFirstResponder()
    }
    
    private func configureNavigationBar() {
        navigationItem.title = conversation?.name
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func configureTableView() {
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Const.estimatedRowHeight
    }
    
    private func assembleGroupedMessages() {
        let groupedMessages = Dictionary(grouping: ConversationApi.messages) { (element) -> Date in
            // reduceToMonthDayYear - помогает сгруппировать сообщения именно по дате, без учета времени
            return element.date?.reduceToMonthDayYear() ?? ConversationApi.getDefaultDate()
        }
        let sortedKeys = groupedMessages.keys.sorted()
        sortedKeys.forEach { (key) in
            let values = groupedMessages[key]
            chatMessages.append(values ?? [])
        }
    }
    
    private func scrollToBottom() {
        if shouldScrollToBottom {
            shouldScrollToBottom = false
            let bottomOffset = CGPoint(x: 0, y: max(-tableView.contentInset.top, tableView.contentSize.height - (tableView.bounds.size.height - EntryMessageView.entyMessageViewHight)))
            tableView.setContentOffset(bottomOffset, animated: false)
        }
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
        return chatMessages.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatMessageCell.identifier,
            for: indexPath)
        guard let messageCell = cell as? ChatMessageCell else {
            return cell
        }
        let message = chatMessages[indexPath.section][indexPath.row]
        messageCell.configureCell(message)
        return messageCell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let firstMessageInSection = chatMessages[section].first {
            let dateLabel = DateHeaderLabel()
            dateLabel.configureDate(date: firstMessageInSection.date!)
            return getContainerView(dateLabel)
        }
        return nil
    }
    
    private func getContainerView(_ subView: DateHeaderLabel) -> UIView {
        let containerView = UIView()
        containerView.addSubview(subView)
        subView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        subView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        return containerView
    }
}

// Настройка view для ввода сообщения.
extension ConversationViewController {

    override var inputAccessoryView: UIView? {
        get {
            if entreMessageBar == nil {
                entreMessageBar = Bundle.main.loadNibNamed("EntryMessageView", owner: self, options: nil)?.first as? EntryMessageView
            }
            return entreMessageBar
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var canResignFirstResponder: Bool {
        return true
    }
}

// Отображение даты для секций сообщений.
class DateHeaderLabel: UILabel {
    
    private let formatter = DateFormatter()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        let height = originalContentSize.height + Const.heightSpace
        layer.cornerRadius = height / 2
        layer.masksToBounds = true
        return CGSize(width: originalContentSize.width + Const.widthSpace, height: height)
    }
    
    func configureDate(date: Date) {
        formatter.dateFormat = "dd/MM/yyyy"
        self.text = formatter.string(from: date)
    }
    
    private func configureView() {
        backgroundColor = UIColor(named: "DataChatIndicatorColor")
        textColor = .black
        textAlignment = .center
        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont.systemFont(ofSize: 12, weight: .semibold)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private enum Const {
        static let heightSpace: CGFloat = 5
        static let widthSpace: CGFloat = 20
    }
}

extension Date {
    
    // reduceToMonthDayYear - помогает сгруппировать сообщения именно по дате, без учета времени
    func reduceToMonthDayYear() -> Date {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        let year = calendar.component(.year, from: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.date(from: "\(day)/\(month)/\(year)") ?? Date()
    }
}
