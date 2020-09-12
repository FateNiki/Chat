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

    
    // MARK: - Lifecycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setApplicationState(.Inactive, by: #function)
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        setApplicationState(.Active, by: #function)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        setApplicationState(.Inactive, by: #function)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        setApplicationState(.Background, by: #function)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        setApplicationState(.Inactive, by: #function)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        setApplicationState(.NotRunning, by: #function)
    }
    
    
}

