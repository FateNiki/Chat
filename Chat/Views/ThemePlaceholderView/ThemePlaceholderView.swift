//
//  ThemePlaceholderView.swift
//  Chat
//
//  Created by Алексей Никитин on 05.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class ThemePlaceholderView: UIView {
    // MARK: - Interface variables
    static private let activeBorderColor = UIColor(red: 0.00, green: 0.48, blue: 1.00, alpha: 1.00).cgColor
    static private let inactiveBorderColor = UIColor(red: 0.59, green: 0.59, blue: 0.59, alpha: 1.00).cgColor
    
    // MARK: - Outlets
    @IBOutlet weak var messagesContainer: UIView!
    @IBOutlet weak var incomePlaceholderLabel: PaddingLabel!
    @IBOutlet weak var outcomePlaceholderLabel: PaddingLabel!
    @IBOutlet weak var themeNameLabel: UILabel!
    
    // MARK: - Variables
    private(set) var isActive: Bool = false
    private(set) var themeName: ThemeName? {
        didSet {
            updateView()
        }
    }

    
    // MARK: - Create from xib
    private func initViewFromXib() -> UIView? {
        let xibName = String(describing: type(of: self))
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: xibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateView()
    }
    
    
    // MARK: - Interface configuring
    private func setupView() {
        guard let xibView = initViewFromXib() else { return }
        xibView.frame = self.bounds
        xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(xibView)
        
        messagesContainer.layer.cornerRadius = 14
        messagesContainer.clipsToBounds = true
        incomePlaceholderLabel.layer.cornerRadius = 10
        incomePlaceholderLabel.clipsToBounds = true
        outcomePlaceholderLabel.layer.cornerRadius = 10
        outcomePlaceholderLabel.clipsToBounds = true
    }
    
    private func updateView() -> Void {
        guard let theme = themeName?.theme else { return }
        
        messagesContainer.backgroundColor = theme.backgroundColor
        messagesContainer.layer.borderWidth = isActive ? 3 : 1
        messagesContainer.layer.borderColor = isActive ? Self.activeBorderColor : Self.inactiveBorderColor
        
        themeNameLabel.text = themeName?.rawValue
        themeNameLabel.textColor = theme.textColor
        incomePlaceholderLabel.backgroundColor = theme.incomeMessageCellColor
        incomePlaceholderLabel.textColor = theme.incomeMessageTextColor
        outcomePlaceholderLabel.backgroundColor = theme.outcomeMessageCellColor
        outcomePlaceholderLabel.textColor = theme.outcomeMessageTextColor
    }
}

extension ThemePlaceholderView: ConfigurableView {
    func configure(with model: ThemeName) {
        themeName = model
    }
}
