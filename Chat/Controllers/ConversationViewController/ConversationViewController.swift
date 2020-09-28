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
    private let incomeMessageCellIdentifier = String(describing: IncomeMessageTableViewCell.self)
    private let outcomeMessageCellIdentifier = String(describing: OutcomeMessageTableViewCell.self)

    // MARK: - Variables
    var conversation: Conversation?
    var messages = messagesMock.shuffled()
    
    // MARK: - UI Variables
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame, style: .plain)
        tableView.register(UINib(nibName: incomeMessageCellIdentifier, bundle: nil), forCellReuseIdentifier: incomeMessageCellIdentifier)
        tableView.register(UINib(nibName: outcomeMessageCellIdentifier, bundle: nil), forCellReuseIdentifier: outcomeMessageCellIdentifier)
        tableView.dataSource = self
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
        navigationItem.title = conversation?.user.fullName ?? "Untitled"
    }
}


extension ConversationViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { messages.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if indexPath.row % 2 == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: incomeMessageCellIdentifier) ?? UITableViewCell()
            if let messageCell = cell as? IncomeMessageTableViewCell {
                messageCell.configure(with: .init(message: messages[indexPath.row].text))
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: outcomeMessageCellIdentifier) ?? UITableViewCell()
            if let messageCell = cell as? OutcomeMessageTableViewCell {
                messageCell.configure(with: .init(message: messages[indexPath.row].text))
            }
        }
        
        return cell
    }
    
        
}
