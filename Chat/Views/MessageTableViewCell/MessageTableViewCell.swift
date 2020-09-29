//
//  IncomeMessageTableViewCell.swift
//  Chat
//
//  Created by Алексей Никитин on 28.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var messageLabel: PaddingLabel!
    
    // MARK: - UI Variables
    private lazy var incomePadding: NSLayoutConstraint = {
        return messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10)
    }()
    
    private lazy var outcomePadding: NSLayoutConstraint = {
        return messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
    }()
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        messageLabel.layer.borderWidth = 2
        messageLabel.layer.borderColor = UIColor.lightGray.cgColor
        messageLabel.layer.cornerRadius = 10
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = nil
        incomePadding.isActive = false
        outcomePadding.isActive = false
    }
}

extension MessageTableViewCell: ConfigurableView {
    func configure(with model: MessageCellModel) {
        messageLabel.text = model.message
        incomePadding.isActive = model.income
        outcomePadding.isActive = !model.income
    }
}
