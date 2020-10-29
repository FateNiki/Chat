//
//  RootViewController.swift
//  Chat
//
//  Created by Алексей Никитин on 29.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class RootNavigationViewController: UINavigationController {
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.heightAnchor.constraint(equalToConstant: 30).isActive = true
        indicator.widthAnchor.constraint(equalToConstant: 30).isActive = true
        indicator.layer.zPosition = 1
        indicator.stopAnimating()
        return indicator
    }()
    
    var isReady: Bool = false {
        didSet {
            view.isUserInteractionEnabled = isReady
            if isReady {
                activityIndicator.stopAnimating()
            } else {
                activityIndicator.startAnimating()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        isReady = false
        CoreDataStack.shared.config {
            DispatchQueue.main.async {
                self.isReady = true
                self.pushViewController(ConversationsListViewController(), animated: true)
            }
        }
    }
}
