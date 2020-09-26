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
    private let conversationCellIdentifier = String(describing: ConversationTableViewCell.self)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame, style: .plain)
        tableView.register(UINib(nibName: conversationCellIdentifier, bundle: nil), forCellReuseIdentifier: conversationCellIdentifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
    }
    
    private func configUI() {
        view.addSubview(tableView)
        navigationItem.title = "Tinkoff Chat"
    }

}

extension ConversationsListViewController: UITableViewDelegate {    
}

extension ConversationsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ConversationTableViewCell = tableView.dequeueReusableCell(withIdentifier: conversationCellIdentifier, for: indexPath) as! ConversationTableViewCell
        let date = Calendar.current.date(byAdding: .hour, value: -10, to: Date())!

        cell.configure(with: .init(name: "Test User", message: "", date: date, isOnline: Bool.random(), hasUnreadMessage: Bool.random()))
        return cell
    }
    
}
