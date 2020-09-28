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
    private static let onlineColor = UIColor(red: 1.00, green: 1.00, blue: 0.85, alpha: 1.00)
    private static let fontSize: CGFloat = 15
    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        nameLabel.text = nil
        dateLabel.text = nil
        lastMessageLabel.text = nil
    }
}

extension ConversationsTableViewCell: ConfigurableView {
    func configure(with model: ConversationCellModel) {
        nameLabel.text = model.name
        
        lastMessageLabel.text = model.message.isEmpty ? "No messages yet" : model.message
        lastMessageLabel.font = UIFont.systemFont(ofSize: Self.fontSize, weight: model.hasUnreadMessage ? .heavy : .regular)
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        if let yesterday = yesterday, model.date.timeIntervalSince1970 < yesterday.timeIntervalSince1970 {
            dateLabel.text = Self.dateFormatter.string(from: model.date)
        } else {
            dateLabel.text = Self.timeFormatter.string(from: model.date)
        }
        
        contentView.backgroundColor = model.isOnline ? Self.onlineColor : .none
        
    }
}
