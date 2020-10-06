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
    var secondBackgroundColor: UIColor { get }
    var textColor: UIColor { get }
    
    //Converation cell
    var onlineConverationCellColor: UIColor { get }
    var onlineConverationCellTextColor: UIColor { get }
    
    // Message cell
    var incomeMessageCellColor: UIColor { get }
    var incomeMessageTextColor: UIColor { get }
    var outcomeMessageCellColor: UIColor { get }
    var outcomeMessageTextColor: UIColor { get }
}

extension Theme {
    var onlineConverationCellColor: UIColor {
        UIColor(red: 1.00, green: 1.00, blue: 0.85, alpha: 1.00)
    }
    
    var onlineConverationCellTextColor: UIColor { .black }
}

struct ClassicTheme: Theme {
    var backgroundColor: UIColor = .white
    var secondBackgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
    var textColor: UIColor = .black
    
    var incomeMessageCellColor: UIColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.00)
    var outcomeMessageCellColor: UIColor = UIColor(red: 0.86, green: 0.97, blue: 0.77, alpha: 1.00)
    var incomeMessageTextColor: UIColor = .black
    var outcomeMessageTextColor: UIColor = .black
}

struct DayTheme: Theme {
    var backgroundColor: UIColor = .white
    var secondBackgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
    var textColor: UIColor = .black
    
    var incomeMessageCellColor: UIColor = UIColor(red: 0.92, green: 0.92, blue: 0.93, alpha: 1.00)
    var outcomeMessageCellColor: UIColor = UIColor(red: 0.26, green: 0.54, blue: 0.98, alpha: 1.00)
    var incomeMessageTextColor: UIColor = .black
    var outcomeMessageTextColor: UIColor = .white
}

struct NightTheme: Theme {
    var backgroundColor: UIColor = .black
    var secondBackgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.00)
    var textColor: UIColor = .white
    
    var incomeMessageCellColor: UIColor = UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1.00)
    var outcomeMessageCellColor: UIColor = UIColor(red: 0.36, green: 0.36, blue: 0.36, alpha: 1.00)
    var incomeMessageTextColor: UIColor = .white
    var outcomeMessageTextColor: UIColor = .white
}

enum ThemeName: String, CaseIterable {
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
    private static let keyForStorage = "currentTheme"
    
    private(set) var currentThemeName: ThemeName? {
        didSet {
            apply()
        }
    }
    
    private init() {}
    
    public func load() -> Void {
        let storedThemeAsAny = UserDefaults.standard.value(forKey: Self.keyForStorage)
        
        if let storedThemeAsString = storedThemeAsAny as? String,
           let storedThemeName = ThemeName(rawValue: storedThemeAsString) {
            currentThemeName = storedThemeName
        } else {
            currentThemeName = .classic
        }

    }
    
    private func save(newTheme: ThemeName) -> Void {
        UserDefaults.standard.set(newTheme.rawValue, forKey: Self.keyForStorage)
        currentThemeName = newTheme
    }
    
    private func apply() -> Void {
        guard let theme = currentThemeName?.theme else { return }
        
        
        // ThemedView
        ThemedView.appearance().backgroundColor = theme.backgroundColor
        UILabel.appearance(whenContainedInInstancesOf: [ThemedView.self]).textColor = theme.textColor
        UILabel.appearance(whenContainedInInstancesOf: [UserAvatarView.self, ThemedView.self]).textColor = UIColor(red: 0.21, green: 0.22, blue: 0.22, alpha: 1.00)
       
        // UITableView
        UITableView.appearance().backgroundColor = theme.backgroundColor
        
        // NavigationBar
        UINavigationBar.appearance().barTintColor = theme.secondBackgroundColor
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: theme.textColor]
        
        // ConversationsTableViewCell
        ConversationsTableViewCell.appearance().backgroundColor = theme.backgroundColor
        ConversationsTableViewCell.appearance().primaryTextColor = theme.textColor
        ConversationsTableViewCell.appearance().onlineBackgroundColor = theme.onlineConverationCellColor
        ConversationsTableViewCell.appearance().onlineNameTextColor = theme.onlineConverationCellTextColor
        
        // MessageTableViewCell
        MessageTableViewCell.appearance().backgroundColor = theme.backgroundColor
        MessageTableViewCell.appearance().incomeMessageCellColor = theme.incomeMessageCellColor
        MessageTableViewCell.appearance().outcomeMessageCellColor = theme.outcomeMessageCellColor
        MessageTableViewCell.appearance().incomeMessageTextColor = theme.incomeMessageTextColor
        MessageTableViewCell.appearance().outcomeMessageTextColor = theme.outcomeMessageTextColor
    }
}

extension ThemeManager: ThemePickerDelegate {
    func pickTheme(with name: ThemeName) {
        save(newTheme: name)
    }
}
