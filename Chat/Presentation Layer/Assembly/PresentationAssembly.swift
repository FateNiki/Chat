//
//  PresentationAssembly.swift
//  Chat
//
//  Created by Алексей Никитин on 09.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation
import UIKit

protocol PresentationAssemblyProtocol {
    /// Создает экран редактирования и просмотра пользователя
    func userViewController() -> UserViewController
}

class PresentationAssembly: PresentationAssemblyProtocol {
    private let serviceAssembly: ServicesAssemblyProtocol
    
    init(serviceAssembly: ServicesAssemblyProtocol) {
        self.serviceAssembly = serviceAssembly
    }
    
    // MARK: - UserViewController    
    func userViewController() -> UserViewController {
        let model = userViewModel()
        let userVC = UserViewController(model: model)
        model.delegate = userVC
        return userVC
    }
    
    private func userViewModel() -> UserViewModelProtocol {
        return UserViewModel(userService: serviceAssembly.getUserService(for: .gcd))
    }
}
