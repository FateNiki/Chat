//
//  Theme.swift
//  Chat
//
//  Created by Алексей Никитин on 02.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

protocol Theme {
    var backgroundColor: UIColor { get }
    var textColor: UIColor { get }
    
    //Converation cell
    var onlineConverationCellColor: UIColor { get }
    var onlineConverationCellTextColor: UIColor { get }
}

extension Theme {
    var onlineConverationCellColor: UIColor {
        UIColor(red: 1.00, green: 1.00, blue: 0.85, alpha: 1.00)
    }
    
    var onlineConverationCellTextColor: UIColor { .black }
}

struct ClassicTheme: Theme {
    var backgroundColor: UIColor { .white }
    var textColor: UIColor { .black }
}

struct DayTheme: Theme {
    var backgroundColor: UIColor { .blue }
    var textColor: UIColor { .white }
}

struct NightTheme: Theme {
    var backgroundColor: UIColor { .black }
    var textColor: UIColor { .white }
}

enum ThemeName: String {
    case classic, day, night
    
    var theme: Theme {
        switch self {
            case .classic:
                return ClassicTheme()
            case .night:
                return NightTheme()
            case .day:
                return DayTheme()
        }
    }
}

class ThemeManager {
    static let shared = ThemeManager()
    
    private(set) var currentTheme: ThemeName
    
    private init() {
        currentTheme = ThemeName.classic
    }
    
    public func load() -> Void {
        apply()        
    }
    
    public func save(newTheme: ThemeName) -> Void {
        currentTheme = newTheme
        apply()
    }
    
    private func apply() -> Void {
        let theme = currentTheme.theme
        
        UITableView.appearance().backgroundColor = theme.backgroundColor
        
        // ConversationsTableViewCell
        ConversationsTableViewCell.appearance().backgroundColor = theme.backgroundColor
        ConversationsTableViewCell.appearance().nameTextColor = theme.textColor
        ConversationsTableViewCell.appearance().onlineBackgroundColor = theme.onlineConverationCellColor
        ConversationsTableViewCell.appearance().onlineNameTextColor = theme.onlineConverationCellTextColor

    }
}
