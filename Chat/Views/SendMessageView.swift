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
        messageView.translatesAutoresizingMaskIntoConstraints = false
        messageView.font = UIFont.systemFont(ofSize: 16)
        messageView.delegate = self
        return messageView
    }()
    private lazy var sendButton: UIButton = {
        let sendButton = UIButton(type: .custom)
        sendButton.setImage(UIImage(named: "icon_send"), for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonDidTap), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.isHidden = true
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
        
        containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        
        messageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0.5).isActive = true
        messageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0.5).isActive = true
        messageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        messageView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10).isActive = true
        
        sendButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -9).isActive = true
        sendButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5).isActive = true
        sendButton.widthAnchor.constraint(equalTo: sendButton.heightAnchor).isActive = true
        
        messageView.sizeToFit()
    }
    
    // MARK: - Action
    @objc private func sendButtonDidTap() {
        guard !messageView.text.isEmpty else { return }
        delegate?.sendMessage(with: messageView.text)
        messageView.text = ""
    }
}

extension SendMessageView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        sendButton.isHidden = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
