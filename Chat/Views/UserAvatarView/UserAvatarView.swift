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
    
    // MARK: - Outlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var initialsLabel: UILabel!

    // MARK: - Config view
    private func initViewFromXib() -> UIView? {
        let xibName = String(describing: type(of: self))
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: xibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    private func setupViews() {
        guard let xibView = initViewFromXib() else { return }
        xibView.frame = self.bounds
        xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(xibView)
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configAvatarImageView()        
    }
    
    
    // MARK: - Interface configuring
    private func configAvatarImageView() -> Void {
        let minSize = min(avatarImageView.layer.frame.width, avatarImageView.layer.frame.height)
        avatarImageView.layer.cornerRadius = minSize / 2
        avatarImageView.backgroundColor = avatarBackground
        initialsLabel.font = initialsLabel.font.withSize(minSize/3)
    }

}

extension UserAvatarView: ConfigurableView {
    func configure(with model: User) {
        if let avatarImageData = model.avatar {
            avatarImageView.image = UIImage(data: avatarImageData)
            initialsLabel.isHidden = true
        } else {
            initialsLabel.isHidden = false
            initialsLabel.text = model.initials
        }
    }
}
