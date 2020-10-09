//
//  MessageView.swift
//  Chat
//
//  Created by Алексей Никитин on 09.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class MessageView: UIView {
    // MARK: - Interface constants
    private static let cornerRadius = CGFloat(10)
    var textColor: UIColor?
    
    // MARK: - Outlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var view: UIView!

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
        
        self.layer.cornerRadius = Self.cornerRadius
        self.clipsToBounds = true
        messageLabel.backgroundColor = nil
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func updateView() -> Void {
        view.backgroundColor = backgroundColor
        messageLabel.textColor = textColor        
    }
}

extension MessageView: ConfigurableView {
    func configure(with model: MessageCellModel?) {
        guard let message = model else {
            messageLabel.text = nil
            return
        }
        messageLabel.text = "\(message.text) | \(message.income ? "income" : "outcome")"
        updateView()
    }
}
