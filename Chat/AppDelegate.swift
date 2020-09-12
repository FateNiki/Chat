//
//  AppDelegate.swift
//  Chat
//
//  Created by Алексей Никитин on 12.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

enum ApplicationState {
    case NotRunning
    case Inactive
    case Active
    case Background
    case Suspended
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var currentState: ApplicationState = .NotRunning
    
    private func setApplicationState(_ newState: ApplicationState, by method: String) {
        #if DEBUG
            print("Application moved from \(currentState) to \(newState): \(method)")
        #endif
        currentState = newState
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setApplicationState(.Inactive, by: #function)
        return true
    }
}

