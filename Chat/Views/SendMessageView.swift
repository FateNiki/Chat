//
//  SendMessageView.swift
//  Chat
//
//  Created by Алексей Никитин on 19.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class SendMessageView: UIView {
    
    
    // MARK: - UI Variables
    private lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.layer.borderWidth = 1
        containerView.layer.cornerRadius = 16
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = true
        return containerView
    }()
    private lazy var messageView: UITextView = {
        let messageView = UITextView()
        messageView.text = "placeholder"
        messageView.translatesAutoresizingMaskIntoConstraints = false
        messageView.font = UIFont.systemFont(ofSize: 17)
        return messageView
    }()
    private lazy var sendButton: UIButton = {
        let sendButton = UIButton()
        sendButton.titleLabel?.text = "Send"
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        return sendButton
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Interface configuring
    private func setupView() {
        self.addSubview(containerView)
        self.addSubview(messageView)
        self.addSubview(sendButton)
        
        containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -18).isActive = true
        containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 18).isActive = true
        containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        
        messageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18).isActive = true
        messageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2).isActive = true
        messageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -2).isActive = true
        
        sendButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18).isActive = true
        sendButton.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        messageView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10).isActive = true
    }
}
