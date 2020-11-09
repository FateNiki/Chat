//
//  PresentationAssembly.swift
//  Chat
//
//  Created by Алексей Никитин on 09.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation
import UIKit

class Router {
    private let presentationAssembly: PresentationAssemblyProtocol
    
    init(presentationAssembly: PresentationAssemblyProtocol) {
        self.presentationAssembly = presentationAssembly
    }
    
    lazy var rootController: RootNavigationViewController = presentationAssembly.rootController(router: self)

    func openUserView(modalFor controller: UIViewController) {
        let userVC = presentationAssembly.userViewController()
        controller.present(userVC, animated: true, completion: nil)
    }
    
    func openConverationsList(in navigation: UINavigationController) {
        let converationsVC = presentationAssembly.conversationsListViewController(router: self)
        navigation.pushViewController(converationsVC, animated: true)
    }
}

protocol PresentationAssemblyProtocol {
    func rootController(router: Router) -> RootNavigationViewController
    
    /// Создает экран редактирования и просмотра пользователя
    func userViewController() -> UserViewController
    
    func conversationsListViewController(router: Router) -> ConversationsListViewController
}

class PresentationAssembly: PresentationAssemblyProtocol {
    private let serviceAssembly: ServicesAssemblyProtocol
    
    init(serviceAssembly: ServicesAssemblyProtocol) {
        self.serviceAssembly = serviceAssembly
    }
    
    // MARK: - Root
    func rootController(router: Router) -> RootNavigationViewController {
        RootNavigationViewController(router: router)
    }
    
    // MARK: - conversationsListViewController
    func conversationsListViewController(router: Router) -> ConversationsListViewController {
        let service = serviceAssembly.getUserService(for: .gcd)
        return ConversationsListViewController(router: router, service: service)
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
