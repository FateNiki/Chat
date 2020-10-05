//
//  ConversationsTableViewCell.swift
//  Chat
//
//  Created by Алексей Никитин on 26.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class ConversationsTableViewCell: UITableViewCell {
    // MARK: - static variables
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateFormat = "dd MMM"
        return formatter
    }()
    private static var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    // MARK: - Interface constants
    @objc dynamic var onlineBackgroundColor: UIColor? = UIColor(red: 1.00, green: 1.00, blue: 0.85, alpha: 1.00)
    @objc dynamic var nameTextColor = UIColor.black
    @objc dynamic var onlineNameTextColor = UIColor.black
    let fontSize: CGFloat = 15
    
    // MARK: - Variables
    private var userIsOnline: Bool = false {
        didSet {
            updateViewColors()
        }
    }

    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        dateLabel.text = nil
        lastMessageLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateViewColors()
    }
    
    
    // MARK: - Interface configuring
    private func updateViewColors() -> Void {
        if (userIsOnline) {
            contentView.backgroundColor = onlineBackgroundColor
            nameLabel.textColor = onlineNameTextColor
        } else {
            contentView.backgroundColor = backgroundColor
            nameLabel.textColor = nameTextColor
        }
    }
}

extension ConversationsTableViewCell: ConfigurableView {
    func configure(with model: ConversationCellModel) {
        userIsOnline = model.isOnline
        nameLabel.text = model.name
        
        if model.message.isEmpty {
            lastMessageLabel.text =  "No messages yet"
            lastMessageLabel.font = UIFont.italicSystemFont(ofSize: fontSize)
        } else {
            lastMessageLabel.text = model.message
            lastMessageLabel.font = UIFont.systemFont(ofSize: fontSize, weight: model.hasUnreadMessage ? .heavy : .regular)
        }
        
        if (!model.message.isEmpty) {
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
            if let yesterday = yesterday, model.date.timeIntervalSince1970 < yesterday.timeIntervalSince1970 {
                dateLabel.text = Self.dateFormatter.string(from: model.date)
            } else {
                dateLabel.text = Self.timeFormatter.string(from: model.date)
            }
        } else {
            dateLabel.text = nil
        }
    }
}
