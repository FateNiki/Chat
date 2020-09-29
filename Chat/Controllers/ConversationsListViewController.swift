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
    private let currentUser = mockUser
    
    // MARK: - UI Variables
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame, style: .plain)
        tableView.register(UINib(nibName: conversationCellIdentifier, bundle: nil), forCellReuseIdentifier: conversationCellIdentifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    private lazy var userAvatarView: UserAvatarView = {
        let uaView = UserAvatarView()
        uaView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        uaView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        uaView.configure(with: currentUser)
        uaView.delegate = self
        return uaView
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        updateView()
    }
    
    // MARK: - Config UI
    private func setupView() {
        initTableView()
        initNavigation()
    }
    
    private func updateView() {
        tableView.frame = view.frame
    }
    
    private func initTableView() {
        view.addSubview(tableView)
    }
    
    private func initNavigation() {
        navigationItem.title = "Tinkoff Chat"
        
        let userButton = UIBarButtonItem(customView: userAvatarView)
        navigationItem.rightBarButtonItem = userButton
    }
    
    // MARK: - Actions
    func openUserEdit() -> Void {
        let userController = UserViewController()
        userController.currentUser = currentUser
        self.present(userController, animated: true, completion: nil)
    }
    
    func openConversation(with conversation: Conversation) -> Void {
        let conversationController = ConversationViewController()
        conversationController.conversation = conversation
        navigationController?.pushViewController(conversationController, animated: true)
    }

}

extension ConversationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = conversations.withStatus(online: indexPath.section == 0)[indexPath.row]
        openConversation(with: conversation)
    }
}

extension ConversationsListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.withStatus(online: section == 0).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: conversationCellIdentifier, for: indexPath)
        
        if let conversationCell = cell as? ConversationsTableViewCell {
            let conversation = conversations.withStatus(online: indexPath.section == 0)[indexPath.row]
            conversationCell.configure(with: .init(
                            name: conversation.user.fullName,
                            message: conversation.lastMessage.text,
                            date: conversation.lastMessage.date,
                            isOnline: conversation.isOnline,
                            hasUnreadMessage: !conversation.lastMessage.isRead)
            )
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0: return "Online"
            case 1: return "History"
            default: return nil
        }
        
    }
    
}

extension ConversationsListViewController: UserAvatarViewDelegate {
    func userAvatarDidTap() {
        openUserEdit()
    }
}
