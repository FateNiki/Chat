//
//  IncomeMessageTableViewCell.swift
//  Chat
//
//  Created by Алексей Никитин on 28.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class IncomeMessageTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var messageLabel: UILabel!
    
    override func prepareForReuse() {
        messageLabel.text = nil
    }
}

extension IncomeMessageTableViewCell: ConfigurableView {
    func configure(with model: MessageCellModel) {
        messageLabel.text = model.message
    }
}
