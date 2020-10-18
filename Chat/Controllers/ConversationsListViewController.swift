//
//  ConversationsListViewController.swift
//  Chat
//
//  Created by Алексей Никитин on 26.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit
import Firebase

class ConversationsListViewController: UIViewController {
    // MARK: - Constants
    private let conversationCellIdentifier = String(describing: ConversationsTableViewCell.self)
    private var channels: [Channel]?
    private var currentUser: User? {
        didSet {
            guard let user = currentUser else { return }
            userAvatarView.configure(with: user.avatarModel())
        }
    }
    private lazy var channelsReference: CollectionReference = {
        let db = Firestore.firestore()
        return db.collection(Channel.firebaseCollectionName)
    }()
    
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
        self.addDatabaseListener()
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
    func openUserEdit() {
        guard currentUser != nil else { return }
        
        let userNavigationController = UINavigationController(rootViewController: userViewController)
        self.present(userNavigationController, animated: true, completion: nil)
    }
    
    func openChannel(_ channel: Channel) {
        let conversationController = ConversationViewController()
        conversationController.channel = channel
        conversationController.currentUser = currentUser
        navigationController?.pushViewController(conversationController, animated: true)
    }
    
    @objc func openThemeChoice() {
        navigationController?.pushViewController(themesController, animated: true)
    }

}

extension ConversationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let channel = channels?[indexPath.row] else { return }
        openChannel(channel)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return currentUser == nil ? nil : indexPath
    }
}

extension ConversationsListViewController: UITableViewDataSource {
    func addDatabaseListener() {
        channelsReference.addSnapshotListener { [weak self] (docsSnapshot, _) in
            guard let documents = docsSnapshot?.documents else { return }
            self?.channels = documents.compactMap({ queryDocumentSnapshot -> Channel? in
                let data = queryDocumentSnapshot.data()
                guard let name = data["name"] as? String else { return nil }
                let lastMessage = data["lastMessage"] as? String
                let lastActivity = data["lastActivity"] as? Date
                return Channel(
                    identifier: queryDocumentSnapshot.documentID,
                    name: name,
                    lastMessage: lastMessage,
                    lastActivity: lastActivity
                )
            })
            self?.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { channels?.count ?? 0 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: conversationCellIdentifier, for: indexPath)
        
        if let conversationCell = cell as? ConversationsTableViewCell, let channel = channels?[indexPath.row] {
            conversationCell.configure(with: channel.cellModel())
        }
        return cell
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
