//
//  IncomeMessageTableViewCell.swift
//  Chat
//
//  Created by Алексей Никитин on 28.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    // MARK: - Interface constants
    @objc dynamic var incomeMessageCellColor: UIColor?
    @objc dynamic var incomeMessageTextColor: UIColor?
    @objc dynamic var incomeDateTextColor: UIColor?
    @objc dynamic var outcomeMessageCellColor: UIColor?
    @objc dynamic var outcomeMessageTextColor: UIColor?
    @objc dynamic var outcomeDateTextColor: UIColor?

    private static let labelCornerRadius = CGFloat(10)
    
    // MARK: - Outlets
    @IBOutlet weak var messageContainer: MessageView!
    @IBOutlet weak var incomePadding: NSLayoutConstraint!
    @IBOutlet weak var outcomePadding: NSLayoutConstraint!
    
    // MARK: - Variables
    private var messageIsIncome: Bool = false {
        didSet {
            updateView()
        }
    }
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        messageContainer.configure(with: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateView()
    }
    
    // MARK: - Interface configuring
    private func updateView() {
        contentView.backgroundColor = backgroundColor
        
        messageContainer.backgroundColor = messageIsIncome ? incomeMessageCellColor : outcomeMessageCellColor
        messageContainer.textColor = messageIsIncome ? incomeMessageTextColor : outcomeMessageTextColor
        messageContainer.dateColor = messageIsIncome ? incomeDateTextColor : outcomeDateTextColor
        
        incomePadding.isActive = messageIsIncome
        outcomePadding.isActive = !messageIsIncome
    }
}

extension MessageTableViewCell: ConfigurableView {
    func configure(with model: MessageCellModel) {
        messageContainer.configure(with: model)
        messageIsIncome = model.income
    }
}
