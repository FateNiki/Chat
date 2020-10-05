//
//  ThemesViewController.swift
//  Chat
//
//  Created by Алексей Никитин on 02.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class ThemesViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var classicPlaceholder: ThemePlaceholderView!
    @IBOutlet weak var dayPlaceholder: ThemePlaceholderView!
    @IBOutlet weak var nightPlaceholder: ThemePlaceholderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    // MARK: - Config UI
    private func setupView() {
        navigationItem.title = "Settings"
        classicPlaceholder.configure(with: ThemeName.classic)
        dayPlaceholder.configure(with: ThemeName.day)
        nightPlaceholder.configure(with: ThemeName.night)
        classicPlaceholder.isActive = true
    }
    
    
    private func updateView() {
    }

}
