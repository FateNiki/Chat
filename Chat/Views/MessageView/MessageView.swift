//
//  MessageView.swift
//  Chat
//
//  Created by Алексей Никитин on 09.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class MessageView: UIView {
    // MARK: - Interface constants
    private static let cornerRadius = CGFloat(10)
    var textColor: UIColor? {
        didSet {
            messageLabel.textColor = textColor
        }
    }
    var dateColor: UIColor? {
        didSet {
            dateLabel.textColor = dateColor
        }
    }
    
    // MARK: - UI Elements
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 749), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .vertical)
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 252), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .vertical)
        label.font = UIFont.systemFont(ofSize: 11)
        
        label.text = "17:43"
        return label
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
        self.addSubview(messageLabel)
        self.addSubview(dateLabel)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -10).isActive = true
        messageLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: dateLabel.centerYAnchor).isActive = true
        
        dateLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true

        self.layer.cornerRadius = Self.cornerRadius
        self.clipsToBounds = true
    }
}

extension MessageView: ConfigurableView {
    func configure(with model: MessageCellModel?) {
        guard let message = model else {
            messageLabel.text = nil
            return
        }
        messageLabel.text = "\(message.text) | \(message.income ? "income" : "outcome")"
    }
}
