//
//  ThemePlaceholderView.swift
//  Chat
//
//  Created by Алексей Никитин on 05.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class ThemePlaceholderView: ThemedView {
    // MARK: - Interface variables
    static private let activeBorderColor = UIColor(red: 0.00, green: 0.48, blue: 1.00, alpha: 1.00).cgColor
    static private let inactiveBorderColor = UIColor(red: 0.59, green: 0.59, blue: 0.59, alpha: 1.00).cgColor
    
    // MARK: - Outlets
    @IBOutlet weak var messagesContainer: UIView!
    @IBOutlet weak var incomeMessageView: MessageView!
    @IBOutlet weak var outcomeMessageView: MessageView!
    @IBOutlet weak var themeNameLabel: UILabel!
    
    // MARK: - Variables
    weak var delegate: ThemePlaceholderDelegate?
    var isActive: Bool = false {
        didSet {
            updateActive()
        }
    }
    private(set) var themeName: ThemeName? {
        didSet {
            updateTheme()
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
        incomeMessageView.configure(with: MessageCellModel(text: "Income", date: Date(), senderName: "Sender", income: true))
        outcomeMessageView.configure(with: MessageCellModel(text: "Outcome", date: Date(), senderName: "", income: false))
        
        messagesContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectTheme)))
        themeNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectTheme)))
    }
    
    private func updateView() {
        updateActive()
        updateTheme()
    }
    
    private func updateTheme() {
        guard let theme = themeName?.theme else { return }
        
        themeNameLabel.text = themeName?.rawValue
        messagesContainer.backgroundColor = theme.backgroundColor
        
        incomeMessageView.backgroundColor = theme.incomeMessageCellColor
        incomeMessageView.textColor = theme.incomeMessageTextColor
        incomeMessageView.dateColor = theme.incomeDateTextColor
        
        outcomeMessageView.backgroundColor = theme.outcomeMessageCellColor
        outcomeMessageView.textColor = theme.outcomeMessageTextColor
        outcomeMessageView.dateColor = theme.outcomeDateTextColor
    }
    
    private func updateActive() {
        messagesContainer.layer.borderWidth = isActive ? 3 : 1
        messagesContainer.layer.borderColor = isActive ? Self.activeBorderColor : Self.inactiveBorderColor
    }
    
    // MARK: - Actions
    @objc func selectTheme() {
        if let delegate = delegate, let themeName = themeName {
            delegate.themePlaceholderDidTap(themeName: themeName)
        }
    }
}

extension ThemePlaceholderView: ConfigurableView {
    func configure(with model: ThemeName) {
        themeName = model
    }
}
