//
//  ImageCollectionViewCell.swift
//  Chat
//
//  Created by Алексей Никитин on 19.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imagePreview: UIImageView!
    
    private var imageResult: ImageResult? {
        didSet {
            guard let imageResult = imageResult else {
                imagePreview.image = nil
                imagePreview.isHidden = true
                activityIndicator.stopAnimating()
                return
            }
            switch imageResult {
            case let .success(image):
                imagePreview.image = image
                imagePreview.isHidden = false
                activityIndicator.stopAnimating()
            case let .loading(task):
                imagePreview.image = nil
                imagePreview.isHidden = true
                activityIndicator.startAnimating()
                task.resume()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 8
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let imageResult = imageResult {
            switch imageResult {
            case let .loading(task):
                task.suspend()
            default:
                break
            }
        }
        imageResult = nil
    }
}

extension ImageCollectionViewCell: ConfigurableView {
    func configure(with model: ImageResult) {
        self.imageResult = model
    }
}
