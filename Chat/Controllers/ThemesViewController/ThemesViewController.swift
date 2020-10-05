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
        
        updateColor()
    }
    
    
    private func updateView() {
    }
    
    private func updateColor() {
        let theme = ThemeManager.shared.currentTheme.theme
        view.backgroundColor = theme.backgroundColor
        
        classicPlaceholder.backgroundColor = theme.backgroundColor
        classicPlaceholder.themeNameLabel.textColor = theme.textColor
        
        dayPlaceholder.themeNameLabel.textColor = theme.textColor
        dayPlaceholder.backgroundColor = theme.backgroundColor
        
        nightPlaceholder.themeNameLabel.textColor = theme.textColor
        nightPlaceholder.backgroundColor = theme.backgroundColor
    }

}
