//
//  ViewController.swift
//  Chat
//
//  Created by Алексей Никитин on 12.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

enum ViewControllerState {
    case NotLoad
    case Disappear
    case Appear
}

class ViewController: UIViewController {
    var currentState: ViewControllerState = .NotLoad

    private func setViewControllerState(_ newState: ViewControllerState?, by method: String) {
        guard let newState = newState else {
            #if DEBUG
            print("ViewController is in \(currentState) and call method: \(method)")
            #endif
            return
        }
        
        #if DEBUG
        print("ViewController moved from \(currentState) to \(newState): \(method)")
        #endif
        
        currentState = newState
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewControllerState(.Disappear, by: #function)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setViewControllerState(nil, by: #function)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setViewControllerState(.Appear, by: #function)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setViewControllerState(nil, by: #function)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setViewControllerState(.Disappear, by: #function)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setViewControllerState(nil, by: #function)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setViewControllerState(nil, by: #function)
    }
}

