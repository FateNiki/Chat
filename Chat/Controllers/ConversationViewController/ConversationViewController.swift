//
//  ConversationViewController.swift
//  Chat
//
//  Created by Алексей Никитин on 27.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController {
    // MARK: - Constants
    private let messageCellIdentifier = String(describing: MessageTableViewCell.self)

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
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { messages?.count ?? 0 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: messageCellIdentifier, for: indexPath)
        
        if let messageCell = cell as? MessageTableViewCell, let message = messages?[indexPath.row] {
            messageCell.configure(with: message.cellModel(for: currentUser))
        }
        
        return cell
    }        
}
