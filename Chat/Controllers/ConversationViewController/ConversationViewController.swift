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
        smView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        return smView
    }()

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
        messageDataSource = FirebaseDataSource<Message>(for: tableView, with: messagesQuery)
    }
    
    private func initSendMessageView() {
        view.addSubview(sendMessageView)
        sendMessageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        sendMessageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        sendMessageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
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
