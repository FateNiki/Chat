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
    private lazy var messagesReference: CollectionReference = {
        let db = Firestore.firestore()
        return db.collection(Channel.firebaseCollectionName).document(channel.identifier).collection(Message.firebaseCollectionName)
    }()

    // MARK: - Variables
    var currentUser: User!
    var channel: Channel!
    var messages: [Message]?
    
    // MARK: - UI Variables
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame, style: .plain)
        tableView.register(UINib(nibName: messageCellIdentifier, bundle: nil), forCellReuseIdentifier: messageCellIdentifier)
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
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
        addDatabaseListener()
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
    func addDatabaseListener() {
        messagesReference.addSnapshotListener { [weak self] (docsSnapshot, _) in
            guard let documents = docsSnapshot?.documents else { return }
            self?.messages = documents.compactMap({ queryDocumentSnapshot -> Message? in
                let data = queryDocumentSnapshot.data()
                guard let content = data["content"] as? String,
                      let created = data["created"] as? Timestamp,
                      let senderId = data["senderId"] as? String,
                      let senderName = data["senderName"] as? String
                else { return nil }
                return Message(content: content, created: created.dateValue(), senderId: senderId, senderName: senderName)
            })
            self?.tableView.reloadData()
        }
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { messages?.count ?? 0 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: messageCellIdentifier, for: indexPath)
        
        if let messageCell = cell as? MessageTableViewCell, let message = messages?[indexPath.row] {
            messageCell.configure(with: message.cellModel(for: currentUser))
        }
        
        return cell
    }        
}
