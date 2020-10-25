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
    private var currentUser: User? {
        didSet {
            guard let user = currentUser else { return }
            userAvatarView.configure(with: user.avatarModel())
        }
    }
    private lazy var channelsRef: CollectionReference = {
        let db = Firestore.firestore()
        return db.collection(Channel.firebaseCollectionName)
    }()
    private lazy var channelsQuery = channelsRef
    private var channelDataSource: FirebaseDataSource<Channel>!
    
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
        channelDataSource = FirebaseDataSource<Channel>(for: tableView, with: channelsQuery, refresh: nil)
        GCDUserManager.shared.loadFromFile { (result, _) in
            guard let user = result else { return }
            DispatchQueue.main.async {
                self.currentUser = user
                self.navigationItem.rightBarButtonItems = [
                    UIBarButtonItem(customView: self.userAvatarView),
                    UIBarButtonItem(title: "➕", style: .plain, target: self, action: #selector(self.openCreateChannelAlert))
                ]
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
        navigationItem.title = "Channels"
        
        let userLoadingView = UIActivityIndicatorView()
        userLoadingView.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: userLoadingView)
        
        let settingButton = UIBarButtonItem(title: "⚙️", style: .plain, target: self, action: #selector(openThemeChoice))
        navigationItem.leftBarButtonItem = settingButton
    }
    
    // MARK: - Helpers
    private func createChannel(with name: String) {
        let newChannelRef = channelsRef.document()
        let newChannel = Channel(id: newChannelRef.documentID, name: name)
        newChannelRef.setData(newChannel.data) { [weak self] (error) in
            if let error = error {
                self?.openAlert(title: "Ошибка сохранения", message: error.localizedDescription)
            } else {
                self?.openChannel(newChannel)
            }
        }        
    }
    
    // MARK: - Interface Actions
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
    
    @objc func openCreateChannelAlert() {
        let createAlert = UIAlertController(title: "Новый канал", message: "Введите название нового канала", preferredStyle: .alert)
        createAlert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        createAlert.addAction(UIAlertAction(title: "Создать", style: .default) { [weak createAlert, weak self] (_) in
            guard let textField = createAlert?.textFields?[0], let text = textField.text else { return }
            self?.createChannel(with: text)
        })
        createAlert.addTextField(configurationHandler: nil)
        present(createAlert, animated: true, completion: nil)
    }

}

extension ConversationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = channelDataSource.elements[indexPath.row]
        openChannel(channel)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return currentUser == nil ? nil : indexPath
    }
}

extension ConversationsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        channelDataSource.elements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: conversationCellIdentifier, for: indexPath)
        if let conversationCell = cell as? ConversationsTableViewCell {
            let channel = channelDataSource.elements[indexPath.row]
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
        ThemeManager.shared.saveToFile(data: name) { (savedTheme, _) in
            guard let theme = savedTheme?.theme else { return }

            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
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
