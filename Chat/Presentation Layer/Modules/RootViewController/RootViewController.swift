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
    
    // MARK: - Dependencies
    private let router: Router
    private let model: RootModelProtocol
    
    init(router: Router, model: RootModelProtocol) {
        self.router = router
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        isReady = false
        CoreDataStack.shared.config {
            self.model.loadTheme()            
        }
    }
}

extension RootNavigationViewController: RootModelDelegate {
    func themeDidLoad(themeName: ThemeName) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isReady = true
            self.view.backgroundColor = themeName.theme.backgroundColor
            self.router.openConverationsList(in: self)
        }
    }
}
