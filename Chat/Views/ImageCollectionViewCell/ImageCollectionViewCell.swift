//
//  ImageCollectionViewCell.swift
//  Chat
//
//  Created by Алексей Никитин on 19.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 8
    }

}
