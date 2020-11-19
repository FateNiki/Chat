//
//  ImageLibraryViewController.swift
//  Chat
//
//  Created by Алексей Никитин on 19.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class ImageLibraryViewController: UIViewController {
    // MARK: - Constants
    private let imageCellIdentifier = String(describing: ImageCollectionViewCell.self)
    
    // MARK: - UI Variables
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Lifecycle
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Interface configuring
    private func setupView() {
        configCollectionView()
    }
    
    private func configCollectionView() {
        collectionView.register(UINib(nibName: imageCellIdentifier, bundle: nil), forCellWithReuseIdentifier: imageCellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension ImageLibraryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 10 }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellIdentifier, for: indexPath)
        return cell
    }
}

extension ImageLibraryViewController: UICollectionViewDelegate {
    
}

extension ImageLibraryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 5
        let countOfRows: CGFloat = 3
        let width = (view.bounds.width - (spacing * (countOfRows + 1))) / countOfRows
        guard width > 0 else {
            return .zero
        }
        return CGSize(width: width, height: width)
    }
}
