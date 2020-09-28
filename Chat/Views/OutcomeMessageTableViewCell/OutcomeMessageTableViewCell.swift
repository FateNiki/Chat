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
    
    override func prepareForReuse() {
        messageLabel.text = nil
    }
}

extension OutcomeMessageTableViewCell: ConfigurableView {
    func configure(with model: MessageCellModel) {
        print(model)
        messageLabel.text = model.message
    }
}

