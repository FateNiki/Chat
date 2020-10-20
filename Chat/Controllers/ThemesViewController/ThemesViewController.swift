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
    weak var delegate: ThemePickerDelegate?
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
    func themePlaceholderDidTap(themeName: ThemeName) {
        // Common actions
        updateActive(for: themeName)
        updateColor(for: themeName)
        
        if let delegate = delegate {
            delegate.pickTheme(with: themeName)
        } else if let closure = selectThemeClosure {
            closure(themeName)
        }
        
        /*
         Для оптимизации работы с памятью ThemesVC сделать при помощи конструкции lazy var closure
         Это добавляет сильную ссылку ConversationVC → ThemesVC
         При отрытии ThemesVC он дополнительно помещается в стек NavigationController (дополнительная ссылка)
         
         — В случае использования делегата, ThemesVC держит сильную ссылку на ConversationVC.
                
         — В кейсе использования closure без захвата слабой ссылки (weak self), ThemesVC ссылается на ConversationVC по сильной ссылке через Swift closure context.
         
         — В кейсе с захватом слабой ссылкой на self, ссылок на ConversationVC через DebugMemoryGraph не обнаружено.
         
         После изучения инструмента Debug Memory Graph были сделани следующие выводы:
         1. Первые два случая вызывают retain cycles, однако он не гразит утечкой памяти, тк время жизни ThemesVC гарантитровано меньше чем ConversationVC (ConversationVC является рутовым контроллером навигации).
            Так же ThemesVC вызывается и используется исключительно ConversationVC.
         
         2. Третий кейс позволяет избавиться от дополнительной сильной ссылки, поэтому по умолчанию я оставил его.
            Однако реальных проблем не должен вызвать ни один из данных способов.
         
         Эти выводы подтверждаются так же при мониторинге использования приложения в инструменте Memory Leaks.
         При большом количестве открываний и закрываний ThemesVC количество потребленной памяти не растет.
         */
    }
}
