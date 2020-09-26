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
    // Return the number of rows for the table.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 10
    }

    // Provide a cell object for each row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // Fetch a cell of the appropriate type.
        let cell: ConversationTableViewCell = tableView.dequeueReusableCell(withIdentifier: conversationCellIdentifier, for: indexPath) as! ConversationTableViewCell

       return cell
    }
    
}
