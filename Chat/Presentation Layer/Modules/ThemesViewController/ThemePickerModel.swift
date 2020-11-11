//
//  ThemeModel.swift
//  Chat
//
//  Created by Алексей Никитин on 11.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

protocol ThemePickerDelegate: class {
    func themeDidPick(with name: ThemeName)
}

protocol ThemePickerModelDelegate: class {
    func themeDidSave(themeName: ThemeName)
}

protocol ThemePickerModelProtocol: class {
    var delegate: ThemePickerModelDelegate? { get set }
    var currentTheme: ThemeName { get }
    var themes: [ThemeName] { get }
    
    func applyTheme(with name: ThemeName)
}

class ThemePickerModel: ThemePickerModelProtocol {
    private let themeService: ThemeServiceProtocol
    lazy var themes: [ThemeName] = ThemeName.allCases
    var currentTheme: ThemeName { themeService.currentThemeName }
    weak var delegate: ThemePickerModelDelegate?
    
    init(themeService: ThemeServiceProtocol) {
        self.themeService = themeService
    }
    
    func applyTheme(with name: ThemeName) {
        themeService.saveAndApply(theme: name) { [weak delegate] (savedTheme, _) in
            guard let theme = savedTheme, let delegate = delegate else { return }
            delegate.themeDidSave(themeName: theme)
            
        }
    }
}
