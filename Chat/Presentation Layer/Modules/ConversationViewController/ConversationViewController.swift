//
//  ConversationViewController.swift
//  Chat
//
//  Created by Алексей Никитин on 27.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class ConversationViewController: UIViewController {
    // MARK: - Constants
    private let messageCellIdentifier = String(describing: MessageTableViewCell.self)
    private var messageResultController: NSFetchedResultsController<MessageDB>? {
        didSet {
            guard let controller = messageResultController else { return }
            controller.delegate = self
            try? controller.performFetch()
        }
    }
    
    // MARK: - Dependencies
    private let model: ConversationModelProtocol
    
    // MARK: - Variables
    var user: User
    var channel: Channel
    
    // MARK: - UI Variables
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame, style: .plain)
        tableView.register(UINib(nibName: messageCellIdentifier, bundle: nil), forCellReuseIdentifier: messageCellIdentifier)
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private lazy var sendMessageView: SendMessageView = {
        let smView = SendMessageView()
        smView.translatesAutoresizingMaskIntoConstraints = false
        smView.delegate = self
        return smView
    }()
    private var messageViewBottom: NSLayoutConstraint?
    
    // MARK: - Lifecycle
    init(channel: Channel, user: User, model: ConversationModelProtocol) {
        self.user = user
        self.channel = channel
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = ThemedView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        scrollToBottom(animated: true)
    }
    
    // MARK: - Interface configuring
    private func setupView() {
        initSendMessageView()
        initTableView()
        initNavigation()
        configKeyboard()
        
        messageResultController = model.fetch()
    }
    
    private func configKeyboard() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func initSendMessageView() {
        view.addSubview(sendMessageView)
        sendMessageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        sendMessageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        messageViewBottom = sendMessageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        messageViewBottom!.isActive = true
        view.backgroundColor = SendMessageView.appearance().backgroundColor
    }
    
    private func initTableView() {
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: sendMessageView.topAnchor).isActive = true
    }
    
    private func initNavigation() {
        navigationItem.title = channel.name
        navigationItem.largeTitleDisplayMode = .never
        let titleView = ChannelTitleView()
        titleView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        titleView.configure(with: channel.cellModel())
        navigationItem.titleView = titleView
    }
    
    // MARK: - Inteface Actions
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

        let keyboardScreenEndFrame: CGRect = keyboardValue.cgRectValue

        if notification.name == UIResponder.keyboardWillHideNotification {
            messageViewBottom?.constant = 0
        } else {
            messageViewBottom?.constant = -keyboardScreenEndFrame.height
        }
        
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
            self.scrollToBottom(animated: false)
        }
    }
    
    private func scrollToBottom(animated: Bool) {
        let count = tableView.numberOfRows(inSection: 0)
        if count > 0 {
            let lastIndex = IndexPath(row: count - 1, section: 0)
            tableView.scrollToRow(at: lastIndex, at: .top, animated: animated)
        }
    }
}

extension ConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = messageResultController?.sections else { return 0 }
        return sections[section].numberOfObjects }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: messageCellIdentifier, for: indexPath)
        guard let messageDB = messageResultController?.object(at: indexPath), let message = Message(from: messageDB) else { return cell }

        if let messageCell = cell as? MessageTableViewCell {
            messageCell.configure(with: message.cellModel(for: user))
        }
        return cell
    }
}

extension ConversationViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        scrollToBottom(animated: true)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let insertIndex = newIndexPath else { return }
            tableView.insertRows(at: [insertIndex], with: .automatic)
        case .update:
            guard let updateIndex = indexPath else { return }
            tableView.reloadRows(at: [updateIndex], with: .automatic)
        case .move:
            guard let oldIndex = indexPath, let newIndex = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndex], with: .automatic)
            tableView.insertRows(at: [newIndex], with: .automatic)
        case .delete:
            guard let deleteIndex = indexPath else { return }
            tableView.deleteRows(at: [deleteIndex], with: .automatic)
        @unknown default:
                fatalError("Unknowed chanes")
        }
    }
}

extension ConversationViewController: SendMessageViewDelegate {
    func sendMessage(with text: String) {
        model.createMessage(from: user, with: text)
    }
}

extension ConversationViewController: ConversationModelDelegate {
    func showMessageError(error: String) {
        print("SEND MESSAGE ERROR: \(error)")
    }
}
