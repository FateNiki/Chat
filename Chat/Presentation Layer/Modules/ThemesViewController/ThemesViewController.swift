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
    private var currentTheme: ThemeName? {
        didSet {
            guard let theme = currentTheme else { return }
            DispatchQueue.main.async {
                self.updateActive(for: theme)
                self.updateColor(for: theme)
            }
        }
    }
    weak var delegate: ThemePickerDelegate?
    
    // MARK: - Dependencies
    private let router: Router
    private let model: ThemePickerModelProtocol

    // MARK: - Lifecycle
    init(router: Router, model: ThemePickerModelProtocol) {
        self.router = router
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    // MARK: - Config UI
    private func setupView() {
        navigationItem.title = "Settings"
        navigationItem.largeTitleDisplayMode = .never
        currentTheme = model.currentTheme
    }
    
    // MARK: - Private Methods    
    private func updateActive(for themeName: ThemeName) {
        for (index, theme) in model.themes.enumerated() where index < placeholders.count {
            placeholders[index].configure(with: theme)
            placeholders[index].delegate = self
            placeholders[index].isActive = theme == themeName
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
        model.applyTheme(with: themeName)
    }
}

extension ThemesViewController: ThemePickerModelDelegate {
    func themeDidSave(themeName: ThemeName) {
        currentTheme = themeName
        delegate?.themeDidPick(with: themeName)
    }
}
