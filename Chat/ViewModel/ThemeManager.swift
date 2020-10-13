//
//  ThemeManager.swift
//  Chat
//
//  Created by Алексей Никитин on 13.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class ThemeManager: DataManager {
    static let shared = ThemeManager()
    private static let keyForStorage = "currentTheme"
    
    private(set) var currentThemeName: ThemeName = .classic {
        didSet {
            self.apply()
        }
    }
    
    private init() {}
    
    public func loadFromFile(completion: ((ThemeName) -> Void)?) {
        let storedThemeAsAny = UserDefaults.standard.value(forKey: Self.keyForStorage)
        
        if let storedThemeAsString = storedThemeAsAny as? String,
           let storedThemeName = ThemeName(rawValue: storedThemeAsString) {
            self.currentThemeName = storedThemeName
        } else {
            self.currentThemeName = .classic
        }
        completion?(self.currentThemeName)
    }
    
    func saveToFile(data: ThemeName, completion: ((ThemeName) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            UserDefaults.standard.set(data.rawValue, forKey: Self.keyForStorage)
            self.currentThemeName = data
            completion?(self.currentThemeName)
        }
    }
    
    private func apply() -> Void {
        let theme = currentThemeName.theme
        
        // ThemedView
        ThemedView.appearance().backgroundColor = theme.backgroundColor
        UILabel.appearance(whenContainedInInstancesOf: [ThemedView.self]).textColor = theme.textColor
        UILabel.appearance(whenContainedInInstancesOf: [UserAvatarView.self, ThemedView.self]).textColor = UIColor(red: 0.21, green: 0.22, blue: 0.22, alpha: 1.00)
       
        // UITableView
        UITableView.appearance().backgroundColor = theme.backgroundColor
        
        // NavigationBar
        UINavigationBar.appearance().barTintColor = theme.secondBackgroundColor
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: theme.textColor]
        
        // UITextView
        UITextView.appearance().backgroundColor = theme.backgroundColor
        UITextView.appearance().textColor = theme.textColor
        
        // UITextField
        UITextField.appearance().backgroundColor = theme.backgroundColor
        UITextField.appearance().textColor = theme.textColor
        
        
        // ConversationsTableViewCell
        ConversationsTableViewCell.appearance().backgroundColor = theme.backgroundColor
        ConversationsTableViewCell.appearance().primaryTextColor = theme.textColor
        ConversationsTableViewCell.appearance().onlineBackgroundColor = theme.onlineConverationCellColor
        ConversationsTableViewCell.appearance().onlineNameTextColor = theme.onlineConverationCellTextColor
        
        // MessageTableViewCell
        MessageTableViewCell.appearance().backgroundColor = theme.backgroundColor
        MessageTableViewCell.appearance().incomeMessageCellColor = theme.incomeMessageCellColor
        MessageTableViewCell.appearance().outcomeMessageCellColor = theme.outcomeMessageCellColor
        MessageTableViewCell.appearance().incomeDateTextColor = theme.incomeDateTextColor
        MessageTableViewCell.appearance().outcomeDateTextColor = theme.outcomeDateTextColor
        MessageTableViewCell.appearance().incomeMessageTextColor = theme.incomeMessageTextColor
        MessageTableViewCell.appearance().outcomeMessageTextColor = theme.outcomeMessageTextColor
    }
}