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
    private let conversations: [Conversation] = MessagesMock.conversations
    private var currentUser: User? {
        didSet {
            guard let user = currentUser else { return }
            userAvatarView.configure(with: UserAvatarModel(initials: user.initials, avatar: user.avatar))
        }
    }
    
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
        uaView.delegate = self
        return uaView
    }()
    
    // MARK: - Controllers
    private var userViewController: UserViewController {
        let uvController = UserViewController()
        uvController.delegate = self
        uvController.currentUser = currentUser
        return uvController
    }
    private var themesController: ThemesViewController {
        let themesController = ThemesViewController()
//        themesController.delegate = self
        themesController.selectThemeClosure = { [weak self] (themeName) in
            self?.pickTheme(with: themeName)
        }
        return themesController
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateView()
    }
    
    // MARK: - Config UI
    private func setupView() {
        self.initTableView()
        self.initNavigation()
        GCDUserManager.shared.loadFromFile { result in
            DispatchQueue.main.async {
                self.currentUser = result.user
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.userAvatarView)
            }
        }
    }
    
    private func updateView() {
        tableView.frame = view.frame
    }
    
    private func initTableView() {
        view.addSubview(tableView)
    }
    
    private func initNavigation() {
        navigationItem.title = "Tinkoff Chat"
        
        let userLoadingView = UIActivityIndicatorView()
        userLoadingView.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: userLoadingView)
        
        let settingButton = UIBarButtonItem(title: "⚙️", style: .plain, target: self, action: #selector(openThemeChoice))
        navigationItem.leftBarButtonItem = settingButton
    }
    
    // MARK: - Actions
    func openUserEdit() -> Void {
        guard currentUser != nil else { return }
        
        let userNavigationController = UINavigationController(rootViewController: userViewController)
        self.present(userNavigationController, animated: true, completion: nil)
    }
    
    func openConversation(with conversation: Conversation) -> Void {
        let conversationController = ConversationViewController()
        conversationController.conversation = conversation
        navigationController?.pushViewController(conversationController, animated: true)
    }
    
    @objc func openThemeChoice() -> Void {
        navigationController?.pushViewController(themesController, animated: true)
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
                hasUnreadMessage: !conversation.lastMessage.isRead,
                initials: conversation.user.initials,
                avatar: conversation.user.avatar
            ))
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

extension ConversationsListViewController: ThemePickerDelegate {
    func pickTheme(with name: ThemeName) {
        ThemeManager.shared.saveToFile(data: name) { savedTheme in
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
                
                let theme = savedTheme.theme
                self?.navigationController?.navigationBar.barTintColor = theme.secondBackgroundColor
                self?.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: theme.textColor]
            }
        }
    }
}

extension ConversationsListViewController: UserViewDelegate {
    func userDidChange(newUser: User) {
        currentUser = newUser
    }
}
