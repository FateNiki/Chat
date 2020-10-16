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
    @objc dynamic var primaryTextColor = UIColor.black
    static let secondaryTextColor = UIColor.lightGray
    static let fontSize: CGFloat = 15
    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var avatarView: UserAvatarView!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setViewColors()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        dateLabel.text = nil
        lastMessageLabel.text = nil
        avatarView.avatarImageView.image = nil
    }
    
    // MARK: - Interface configuring
    private func setViewColors() {
        contentView.backgroundColor = backgroundColor
        nameLabel.textColor = primaryTextColor
        lastMessageLabel.textColor = Self.secondaryTextColor
        dateLabel.textColor = Self.secondaryTextColor
    }
}

extension ConversationsTableViewCell: ConfigurableView {
    func configure(with model: ChannelCellModel) {
        nameLabel.text = model.name
        avatarView.configure(with: model)
        
        if let message = model.message {
            lastMessageLabel.text = message
            lastMessageLabel.font = UIFont.systemFont(ofSize: Self.fontSize)
        } else {
            lastMessageLabel.text =  "No messages yet"
            lastMessageLabel.font = UIFont.italicSystemFont(ofSize: Self.fontSize)
        }
        
        if let date = model.date {
            if Calendar.current.isDateInToday(date) {
                dateLabel.text = Self.timeFormatter.string(from: date)
            } else {
                dateLabel.text = Self.dateFormatter.string(from: date)
            }
        } else {
            dateLabel.text = nil
        }
    }
}
