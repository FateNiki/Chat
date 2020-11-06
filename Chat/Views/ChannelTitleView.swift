//
//  ChannelTitleView.swift
//  Chat
//
//  Created by Алексей Никитин on 02.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class ChannelTitleView: UIView {
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let avatarView = UserAvatarView()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Interface configuring
    private func setupView() {
        configTitleLabel()
        configAvatarView()
        
        self.addSubview(titleLabel)
        self.addSubview(avatarView)
        
        avatarView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4).isActive = true
        avatarView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = true
        avatarView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4).isActive = true
        
        titleLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4).isActive = true
        
        avatarView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -10).isActive = true
    }
    
    private func configTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
    }
    
    private func configAvatarView() {
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.widthAnchor.constraint(equalTo: avatarView.heightAnchor).isActive = true
    }
}

extension ChannelTitleView: ConfigurableView {
    func configure(with model: ChannelCellModel) {
        titleLabel.text = model.name
        avatarView.configure(with: model)
    }
}
