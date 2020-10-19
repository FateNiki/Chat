//
//  ConversationViewController.swift
//  Chat
//
//  Created by Алексей Никитин on 27.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit
import Firebase

class ConversationViewController: UIViewController {
    // MARK: - Constants
    private let messageCellIdentifier = String(describing: MessageTableViewCell.self)
    private lazy var messagesRef: CollectionReference = {
        let db = Firestore.firestore()
        return db.collection(Channel.firebaseCollectionName)
            .document(channel.identifier)
            .collection(Message.firebaseCollectionName)
    }()
    private lazy var messagesQuery: Query = messagesRef.order(by: "created", descending: false)
    private var messageDataSource: FirebaseDataSource<Message>!

    // MARK: - Variables
    var currentUser: User!
    var channel: Channel!
    
    // MARK: - UI Variables
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame, style: .plain)
        tableView.register(UINib(nibName: messageCellIdentifier, bundle: nil), forCellReuseIdentifier: messageCellIdentifier)
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    lazy var sendMessageView: SendMessageView = {
        let smView = SendMessageView()
        smView.translatesAutoresizingMaskIntoConstraints = false
        smView.delegate = self
        return smView
    }()
    private var messageViewBottom: NSLayoutConstraint?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    // MARK: - Interface configuring
    private func setupView() {
        initSendMessageView()
        initTableView()
        initNavigation()
        configKeyboard()
        messageDataSource = FirebaseDataSource<Message>(for: tableView, with: messagesQuery) {
            self.scrollToBottom(animated: true)
        }
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
        messageViewBottom = sendMessageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        messageViewBottom!.isActive = true
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
        let lastIndex = IndexPath(row: tableView.numberOfRows(inSection: 0) - 1, section: 0)
        tableView.scrollToRow(at: lastIndex, at: .bottom, animated: animated)
    }
}

extension ConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { messageDataSource.elements.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: messageCellIdentifier, for: indexPath)
        guard let messageCell = cell as? MessageTableViewCell else {
            return cell
        }
        
        let message = messageDataSource.elements[indexPath.row]
        messageCell.configure(with: message.cellModel(for: currentUser))
        
        return messageCell
    }
}

extension ConversationViewController: SendMessageViewDelegate {
    func sendMessage(with text: String) {
        let message = Message(content: text, senderId: currentUser.id, senderName: currentUser.fullName)
        messagesRef.addDocument(data: message.data)
    }
}
