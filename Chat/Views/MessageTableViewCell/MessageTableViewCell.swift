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
    private static let labelBackgroundForIncome = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.00)
    private static let labelBackgroundForOutcome = UIColor(red: 0.86, green: 0.97, blue: 0.77, alpha: 1.00)
    private static let labelTextColor = UIColor.black
    private static let labelCornerRadius = CGFloat(10)
    
    // MARK: - Outlets
    @IBOutlet weak var messageLabel: PaddingLabel!
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
        messageLabel.layer.cornerRadius = Self.labelCornerRadius
        messageLabel.textColor = Self.labelTextColor
        messageLabel.clipsToBounds = true
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
        messageLabel.backgroundColor = messageIsIncome ? Self.labelBackgroundForIncome : Self.labelBackgroundForOutcome
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
