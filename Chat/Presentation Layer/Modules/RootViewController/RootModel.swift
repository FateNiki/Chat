//
//  RootModel.swift
//  Chat
//
//  Created by Алексей Никитин on 12.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

protocol RootModelDelegate: class {
    func themeDidLoad(themeName: ThemeName)
}

protocol RootModelProtocol: class {
    var delegate: RootModelDelegate? { get set }
    
    func loadTheme()
}

class RootModel: RootModelProtocol {
    private let themeService: ThemeServiceProtocol
    weak var delegate: RootModelDelegate?
    
    init(themeService: ThemeServiceProtocol) {
        self.themeService = themeService
    }
    
    func loadTheme() {
        themeService.loadAndApply {[weak delegate] (loadedThemeName, _) in
            guard let delegate = delegate, let theme = loadedThemeName else { return }
            delegate.themeDidLoad(themeName: theme)
        }
    }
}
