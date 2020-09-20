//
//  ViewController.swift
//  Chat
//
//  Created by Алексей Никитин on 12.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: Variables
    private let lightGray = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
    public var currentUser: User = mockUser
    
    // MARK: - Outlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configAvatarImageView()
        configSaveButton()
        
        initUserFields()
    }
    
    // MARK: - Interface configuring
    private func configAvatarImageView() -> Void {
        let minSize = min(avatarImageView.layer.frame.width, avatarImageView.layer.frame.height)
        avatarImageView.layer.cornerRadius = minSize / 2
        avatarImageView.backgroundColor = lightGray
    }
    
    private func configSaveButton() -> Void {
        saveButton.backgroundColor = lightGray
        saveButton.layer.cornerRadius = 14
    }
    
    private func initUserFields() -> Void {
        fullNameLabel.text = currentUser.fullName
        descriptionLabel.text = currentUser.description
    }

}

