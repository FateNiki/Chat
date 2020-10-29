//
//  AppDelegate.swift
//  Chat
//
//  Created by Алексей Никитин on 12.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    // MARK: - Lifecycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let rootNavigationController = RootNavigationViewController()
        window!.rootViewController = rootNavigationController
        window!.makeKeyAndVisible()
        
        ThemeManager.shared.loadFromFile { themeName, _ in
            rootNavigationController.view.backgroundColor = themeName?.theme.backgroundColor
        }
        FirebaseApp.configure()
        
        return true
    }   
}
