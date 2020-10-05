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
    @IBOutlet var placeholders: [ThemePlaceholderView]!
    
    // MARK: - Variables
    var delegate: ThemePickerDelegate?
    var selectThemeClosure: ((ThemeName) -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        
        delegate = ThemeManager.shared
    }
    
    // MARK: - Config UI
    private func setupView() {
        navigationItem.title = "Settings"
        
        for (index, themeName) in ThemeName.allCases.enumerated() where index < placeholders.count {
            placeholders[index].configure(with: themeName)
            placeholders[index].delegate = self
            placeholders[index].isActive = themeName == ThemeManager.shared.currentThemeName
        }
    }
}

extension ThemesViewController {
    private func updateActive(for themeName: ThemeName) {
        for (index, iterableThemeName) in ThemeName.allCases.enumerated() where index < placeholders.count {
            placeholders[index].isActive = iterableThemeName == themeName
        }
    }
    
    private func updateColor(for themeName: ThemeName) {
        let theme = themeName.theme
        view.backgroundColor = theme.backgroundColor
        navigationController?.navigationBar.barTintColor = theme.secondBackgroundColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: theme.textColor]
        
        for placeholder in placeholders {
            placeholder.backgroundColor = theme.backgroundColor
            placeholder.themeNameLabel.textColor = theme.textColor
        }
    }
}

extension ThemesViewController: ThemePlaceholderDelegate {
    func didTap(themeName: ThemeName) {
        // Common actions
        updateActive(for: themeName)
        updateColor(for: themeName)
        
        // delegate
        delegate?.pickTheme(with: themeName)
    }
}
