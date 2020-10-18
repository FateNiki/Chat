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
    private var messageDataSource: FirebaseDataSource<Message>!
    private lazy var messagesQuery: Query = {
        let db = Firestore.firestore()
        return db.collection(Channel.firebaseCollectionName)
            .document(channel.identifier)
            .collection(Message.firebaseCollectionName)
            .order(by: "created", descending: false)
    }()

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
        return tableView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateView()
    }
    
    // MARK: - Interface configuring
    private func setupView() {
        initTableView()
        initNavigation()
        messageDataSource = FirebaseDataSource<Message>(for: tableView, with: messagesQuery)
    }
    
    private func updateView() {
        tableView.frame = view.frame
    }
    
    private func initTableView() {
        view.addSubview(tableView)
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
        
        if let message = messageDataSource.elements[indexPath.row] {
            messageCell.configure(with: message.cellModel(for: currentUser))
        } else {
            messageCell.configure(with: MessageCellModel(text: "ERROR", date: Date(), income: false))
        }
        
        return messageCell
    }        
}
