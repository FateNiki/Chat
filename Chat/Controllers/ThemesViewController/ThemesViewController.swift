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
        
        if let delegate = delegate {
            delegate.pickTheme(with: themeName)
        } else if let closure = selectThemeClosure {
            closure(themeName)
        }
        
        /*
         В случае использования делегата, ThemesVC держит сильную ссылку на ConversationVC.
         Однако, обратной ссылки нет, тк ThemesVC не сохраняется в ConversationVC и сразу передается NavigationController
         Соответственно RC в данном случае не возникает
         
         В кейсе использования closure без захвата слабой ссылки (weak self), ThemesVC ссылается на ConversationVC по сильной ссылке через Swift closure context.
         В кейсе с захватом слабой ссылкой на self, ссылок на ConversationVC через DebugMemoryGraph не обнаружено.
         
         В итоге, в любом из этих случает RC все равно не должен происходить т.к. ThemesVC держится в стеке NavigationController
         И т.к. ThemesVC уничтожается раньше - никаких проблем замечено не было.
         Этот вывод подтверждается так же при мониторинге использования приложения в инструменте Memory Leaks
         */
    }
}
