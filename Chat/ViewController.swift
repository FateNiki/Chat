//
//  ViewController.swift
//  Chat
//
//  Created by Алексей Никитин on 12.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var avatarImageView: UIImageView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configAvatarImageView()
    }
    
    // MARK: - Interface configuring
    private func configAvatarImageView() -> Void {
        let minSize = min(avatarImageView.layer.frame.width, avatarImageView.layer.frame.height)
        avatarImageView.layer.cornerRadius = minSize / 2
        avatarImageView.backgroundColor = .lightGray
    }

}

