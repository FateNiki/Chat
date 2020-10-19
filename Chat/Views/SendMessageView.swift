//
//  SendMessageView.swift
//  Chat
//
//  Created by Алексей Никитин on 19.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class SendMessageView: UIView {            
    // MARK: - Interface constants
    @objc dynamic var borderColor: UIColor?
    
    // MARK: - UI Variables
    private lazy var divider: UIView = {
        let divider = UIView()
        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        divider.translatesAutoresizingMaskIntoConstraints = false
        return divider
    }()
    private lazy var containerView: ThemedView = {
        let containerView = ThemedView()
        containerView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        containerView.layer.borderWidth = 0.5
        containerView.layer.cornerRadius = 16
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = true
        return containerView
    }()
    private lazy var messageView: UITextView = {
        let messageView = UITextView()
        messageView.text = "placeholder"
        messageView.translatesAutoresizingMaskIntoConstraints = false
        messageView.font = UIFont.systemFont(ofSize: 16)
        return messageView
    }()
    private lazy var sendButton: UIButton = {
        let sendButton = UIButton(type: .custom)
        sendButton.setImage(UIImage(named: "icon_send"), for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonDidTap), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        return sendButton
    }()
    
    // MARK: - Variables
    weak var delegate: SendMessageViewDelegate?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateColor()
    }
    
    private func updateColor() {
        divider.backgroundColor = borderColor
        containerView.layer.borderColor = borderColor?.cgColor
    }
    
    // MARK: - Interface configuring
    private func setupView() {
        self.addSubview(divider)
        self.addSubview(containerView)
        containerView.addSubview(messageView)
        containerView.addSubview(sendButton)
        
        divider.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        divider.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        divider.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
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
    
    // MARK: - Action
    @objc private func sendButtonDidTap() {
        guard !messageView.text.isEmpty, let delegate = delegate else {
            return
        }
        
        delegate.sendMessage(with: messageView.text)
    }
}
