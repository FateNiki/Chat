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
    private let rootAssembly = RootAssembly()
    
    var window: UIWindow?

    // MARK: - Lifecycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let rootNavigationController = rootAssembly.router.rootController
        window!.rootViewController = rootNavigationController
        window!.makeKeyAndVisible()
        FirebaseApp.configure()        
        return true
    }   
}
