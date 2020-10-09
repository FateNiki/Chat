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
    @objc dynamic var outcomeMessageCellColor: UIColor?
    @objc dynamic var outcomeMessageTextColor: UIColor?

    private static let labelCornerRadius = CGFloat(10)
    
    // MARK: - Outlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageContainer: UIView!
    @IBOutlet weak var incomePadding: NSLayoutConstraint!
    @IBOutlet weak var outcomePadding: NSLayoutConstraint!
    
    // MARK: - Variables
    private var messageIsIncome: Bool = false {
        didSet {
            updateView()
        }
    }
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        messageContainer.layer.cornerRadius = Self.labelCornerRadius
        messageContainer.clipsToBounds = true
        messageLabel.backgroundColor = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateView()
    }
    
    // MARK: - Interface configuring
    private func updateView() -> Void {
        contentView.backgroundColor = backgroundColor
        
        messageContainer.backgroundColor = messageIsIncome ? incomeMessageCellColor : outcomeMessageCellColor
        messageLabel.textColor = messageIsIncome ? incomeMessageTextColor : outcomeMessageTextColor
        
        incomePadding.isActive = messageIsIncome
        outcomePadding.isActive = !messageIsIncome
    }
}

extension MessageTableViewCell: ConfigurableView {
    func configure(with model: MessageCellModel) {
        messageLabel.text = "\(model.text) | \(model.income ? "income" : "outcome")"
        messageIsIncome = model.income
    }
}
