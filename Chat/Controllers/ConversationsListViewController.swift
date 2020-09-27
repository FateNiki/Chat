//
//  ConversationsListViewController.swift
//  Chat
//
//  Created by Алексей Никитин on 26.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class ConversationsListViewController: UIViewController {
    // MARK: - Constants
    private let conversationCellIdentifier = String(describing: ConversationsTableViewCell.self)
    private let conversations = conversationsMock
    
    // MARK: - UI Variables
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame, style: .plain)
        tableView.register(UINib(nibName: conversationCellIdentifier, bundle: nil), forCellReuseIdentifier: conversationCellIdentifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    // MARK: - Config UI
    private func setupView() {
        initTableView()
        initNavigation()
    }
    
    private func initTableView() {
        view.addSubview(tableView)
    }
    
    private func initNavigation() {
        navigationItem.title = "Tinkoff Chat"
        
        let userButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(openUserEdit))
        navigationItem.rightBarButtonItem = userButton
    }
    
    // MARK: - Actions
    @objc func openUserEdit() -> Void {
        let controller = UserViewController()
        self.present(controller, animated: true, completion: nil)
    }
    
    func openConversation(with conversation: Conversation) -> Void {
        let controller = ConversationViewController()
        controller.conversation = conversation
        navigationController?.pushViewController(controller, animated: true)
    }

}

extension ConversationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isOnline = indexPath.section == 0
        let conversation = conversations.filter({ $0.isOnline == isOnline })[indexPath.row]
        openConversation(with: conversation)
    }
}

extension ConversationsListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let isOnline = section == 0
        return conversations.filter({ $0.isOnline == isOnline }).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ConversationsTableViewCell = tableView.dequeueReusableCell(withIdentifier: conversationCellIdentifier, for: indexPath) as! ConversationsTableViewCell
        
        let isOnline = indexPath.section == 0
        let conversation = conversations.filter({ $0.isOnline == isOnline })[indexPath.row]

        cell.configure(with: .init(
                        name: conversation.user.fullName,
                        message: conversation.lastMessage.text,
                        date: conversation.lastMessage.date,
                        isOnline: conversation.isOnline,
                        hasUnreadMessage: !conversation.lastMessage.isRead)
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0: return "Online"
            case 1: return "History"
            default: return ""
        }
        
    }
    
}
