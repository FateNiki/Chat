//
//  Router.swift
//  Chat
//
//  Created by Алексей Никитин on 19.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class Router: NSObject {
    private let presentationAssembly: PresentationAssemblyProtocol
    
    init(presentationAssembly: PresentationAssemblyProtocol) {
        self.presentationAssembly = presentationAssembly
    }
    
    lazy var rootController: RootNavigationViewController = presentationAssembly.rootController(router: self)

    func openUserView(modalFor controller: UIViewController, delegate: UserViewDelegate?) {
        let userVC = presentationAssembly.userViewController(router: self, delegate: delegate)
        let userNavController = UINavigationController(rootViewController: userVC)
        userNavController.transitioningDelegate = self
        userNavController.modalPresentationStyle = .custom
        controller.present(userNavController, animated: true, completion: nil)
    }
    
    func openConverationsList(in navigation: UINavigationController) {
        let converationsVC = presentationAssembly.conversationsListViewController(router: self)
        navigation.pushViewController(converationsVC, animated: true)
    }
    
    func openConveration(for channel: Channel, user: User, in navigation: UINavigationController) {
        let conversationVC = presentationAssembly.conversationViewController(channel: channel, user: user, router: self)
        navigation.pushViewController(conversationVC, animated: true)
    }
    
    func openThemePicker(in navigation: UINavigationController, delegate: ThemePickerDelegate) {
        let pickerVC = presentationAssembly.themePickerViewController(delegate: delegate, router: self)
        navigation.pushViewController(pickerVC, animated: true)
    }
    
    func openImageLibrary(modalFor controller: UIViewController, delegate: UserAvatarPickerDelegate?) {
        let libraryVC = presentationAssembly.imageLibraryViewController(delegate: delegate)
        let libraryNavController = UINavigationController(rootViewController: libraryVC)
        controller.present(libraryNavController, animated: true)
    }
}

extension Router: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        FadeTransition(dismissing: false)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        FadeTransition(dismissing: true)
    }
}
