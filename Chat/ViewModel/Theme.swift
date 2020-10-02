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
}

struct ClassicTheme: Theme {
    var backgroundColor: UIColor { .white }
}

struct NightTheme: Theme {
    var backgroundColor: UIColor { .black }
}

enum ThemeName: String {
    case classic, day, night
    
    var theme: Theme {
        switch self {
            case .classic:
                return ClassicTheme()
            case .night:
                return NightTheme()
            default:
                return ClassicTheme()
        }
    }
}
