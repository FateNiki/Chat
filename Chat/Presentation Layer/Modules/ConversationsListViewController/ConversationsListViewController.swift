//
//  ConversationsListViewController.swift
//  Chat
//
//  Created by Алексей Никитин on 26.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class ConversationsListViewController: UIViewController {
    // MARK: - Constants
    private let conversationCellIdentifier = String(describing: ConversationsTableViewCell.self)
    private var currentUser: User? {
        didSet {
            guard let user = currentUser else { return }
            userAvatarView.configure(with: user.avatarModel())
        }
    }
    private var channelsResultContoller: NSFetchedResultsController<ChannelDB>? {
        didSet {
            guard let controller = channelsResultContoller else { return }
            controller.delegate = self
            try? controller.performFetch()
        }
    }
    
    // MARK: - UI Variables
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame, style: .plain)
        tableView.register(UINib(nibName: conversationCellIdentifier, bundle: nil), forCellReuseIdentifier: conversationCellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
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
    
    // MARK: - Dependencies
    private let router: Router
    private let model: ConversationsListModelProtocol
        
    // MARK: - Lifecycle
    init(router: Router, model: ConversationsListModelProtocol) {
        self.router = router
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = ThemedView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    // MARK: - Config UI
    private func setupView() {
        self.initTableView()
        self.initNavigation()
        self.channelsResultContoller = model.fetch()
        
        model.loadUser()
    }
    
    private func initTableView() {
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func initNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Channels"
        navigationItem.largeTitleDisplayMode = .always
        
        let userLoadingView = UIActivityIndicatorView()
        userLoadingView.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: userLoadingView)
        
        let settingButton = UIBarButtonItem(image: UIImage(named: "icon_settings"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(openThemeChoice))
        navigationItem.leftBarButtonItem = settingButton
    }
    
    // MARK: - Helpers
    private func createChannel(with name: String) {
        model.createChannel(with: name)
    }
    
    // MARK: - Interface Actions
    func openUserEdit() {
        guard currentUser != nil else { return }
        router.openUserView(modalFor: self)
    }
    
    func openChannel(_ channel: Channel) {
        guard let user = currentUser, let navigation = navigationController else { return }
        router.openConveration(for: channel, user: user, in: navigation)
    }
    
    @objc func openThemeChoice() {
        guard let navigation = navigationController else { return }
        router.openThemePicker(in: navigation)
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
    private func getChannel(at indexPath: IndexPath) -> Channel? {
        guard let channelDB = channelsResultContoller?.object(at: indexPath), let channel = Channel(from: channelDB) else { return nil }
        return channel
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let channel = getChannel(at: indexPath) else { return }
        openChannel(channel)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return currentUser == nil ? nil : indexPath
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete, let channel = getChannel(at: indexPath) else { return }
        model.deleteChannel(channel: channel)
    }
}

extension ConversationsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = channelsResultContoller?.sections else { return 0 }
        return sections[section].numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: conversationCellIdentifier, for: indexPath)
        guard let channel = getChannel(at: indexPath) else { return cell }

        if let conversationCell = cell as? ConversationsTableViewCell {
            conversationCell.configure(with: channel.cellModel())
        }
        return cell
    }
}

extension ConversationsListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
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

extension ConversationsListViewController: UserAvatarViewDelegate {
    func userAvatarDidTap() {
        openUserEdit()
    }
}

extension ConversationsListViewController: ThemePickerDelegate {    
    func themeDidPick(with name: ThemeName) {
        DispatchQueue.main.async { [weak self] in
            let theme = name.theme
            guard let self = self else { return }
            self.tableView.reloadData()
            self.navigationController?.navigationBar.barTintColor = theme.secondBackgroundColor
            self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: theme.textColor]
            self.navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: theme.textColor]
        }
    }
}

extension ConversationsListViewController: UserViewDelegate {
    func userDidChange(newUser: User) {
        currentUser = newUser
    }
}

extension ConversationsListViewController: ConversationsListModelDelegate {
    func channelDidCreate(channel: Channel) {
        self.openChannel(channel)
    }
    
    func showCreatingError(error: String) {
        self.openAlert(title: "Ошибка сохранения", message: error)
    }
    
    func showDeletingError(error: String) {
        self.openAlert(title: "Ошибка удаления", message: error)
    }
    
    func userDidLoad(user: User) {
        DispatchQueue.main.async {
            self.currentUser = user
            self.navigationItem.rightBarButtonItems = [
                UIBarButtonItem(customView: self.userAvatarView),
                UIBarButtonItem(title: "➕", style: .plain, target: self, action: #selector(self.openCreateChannelAlert))
            ]
        }
    }
}
