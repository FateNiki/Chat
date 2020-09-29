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
    @IBOutlet weak var messageLabel: UILabel!
    
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
    }
}

extension MessageTableViewCell: ConfigurableView {
    func configure(with model: MessageCellModel) {
        messageLabel.text = model.message
    }
}
