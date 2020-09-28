//
//  ConfigurableView.swift
//  Chat
//
//  Created by Алексей Никитин on 26.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

protocol ConfigurableView {
    associatedtype ConfigurableModel
    
    func configure(with model: ConfigurableModel)
}
