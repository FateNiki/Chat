//
//  UserAvatarView.swift
//  Chat
//
//  Created by Алексей Никитин on 27.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class UserAvatarView: UIView {
    // MARK: - Interface constants
    private let avatarBackground = UIColor(red: 0.89, green: 0.91, blue: 0.17, alpha: 1.00)
    
    // MARK: - Variables
    var delegate: UserAvatarViewDelegate?
    private(set) var avatar: Data?
    
    // MARK: - Outlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var initialsLabel: UILabel!

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
        
        avatarImageView.backgroundColor = avatarBackground
        self.clipsToBounds = true
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avaratDidTap)))
    }
    
    private func updateView() -> Void {
        let minSize = min(self.bounds.width, self.bounds.height)
        self.layer.cornerRadius = minSize / 2
        initialsLabel.font = initialsLabel.font.withSize(minSize/3)
    }
    
    // MARK: - Action
    @objc func avaratDidTap(_ gestureRecognizer : UITapGestureRecognizer ) {
        delegate?.userAvatarDidTap()
    }

}

extension UserAvatarView: ConfigurableView {
    func configure(with model: UserAvatarModelProtocol) {
        if let avatarImageData = model.avatar {
            avatarImageView.image = UIImage(data: avatarImageData)
            avatar = model.avatar
            initialsLabel.isHidden = true
        } else {
            initialsLabel.isHidden = false
            initialsLabel.text = model.initials
            avatarImageView.image = nil
        }
    }
}
