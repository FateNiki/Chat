//
//  ThemePickerDelegate.swift
//  Chat
//
//  Created by Алексей Никитин on 05.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

protocol ThemePickerDelegate: class {
    func pickTheme(with name: ThemeName) -> Void
}
