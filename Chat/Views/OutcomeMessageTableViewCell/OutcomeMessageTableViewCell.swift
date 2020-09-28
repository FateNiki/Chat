//
//  OutcomeMessageTableViewCell.swift
//  Chat
//
//  Created by Алексей Никитин on 28.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class OutcomeMessageTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = nil
    }
}

extension OutcomeMessageTableViewCell: ConfigurableView {
    func configure(with model: MessageCellModel) {
        messageLabel.text = model.message
    }
}

