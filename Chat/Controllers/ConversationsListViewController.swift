//
//  ConversationsListViewController.swift
//  Chat
//
//  Created by Алексей Никитин on 26.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class ConversationsListViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame)
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
