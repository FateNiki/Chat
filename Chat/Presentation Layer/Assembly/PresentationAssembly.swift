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
        let userVC = presentationAssembly.userViewController(router: self)
        let userNavController = UINavigationController(rootViewController: userVC)
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
    
    func openImageLibrary(modalFor controller: UIViewController) {
        let libraryVC = presentationAssembly.imageLibraryViewController()
        controller.present(libraryVC, animated: true)
    }
}

protocol PresentationAssemblyProtocol {
    /// Создает корневой экран
    func rootController(router: Router) -> RootNavigationViewController
    
    /// Создает экран редактирования и просмотра пользователя
    func userViewController(router: Router) -> UserViewController
    
    /// Создает экран списка диалогов
    func conversationsListViewController(router: Router) -> ConversationsListViewController
    
    /// Создает экран списка сообщений
    func conversationViewController(channel: Channel, user: User, router: Router) -> ConversationViewController
    
    /// Создает экран выбора темы
    func themePickerViewController(delegate: ThemePickerDelegate, router: Router) -> ThemesViewController
    
    /// экран выбора картинки для аватара
    func imageLibraryViewController() -> ImageLibraryViewController
}

class PresentationAssembly: PresentationAssemblyProtocol {
    private let serviceAssembly: ServicesAssemblyProtocol
    
    init(serviceAssembly: ServicesAssemblyProtocol) {
        self.serviceAssembly = serviceAssembly
    }
    
    // MARK: - Root
    func rootController(router: Router) -> RootNavigationViewController {
        let model = rootModel()
        let rootVC = RootNavigationViewController(router: router, model: model)
        model.delegate = rootVC
        return rootVC
    }
    
    private func rootModel() -> RootModelProtocol {
        return RootModel(themeService: serviceAssembly.getThemeService())
    }
    
    // MARK: - UserViewController    
    func userViewController(router: Router) -> UserViewController {
        let model = userModel()
        let userVC = UserViewController(model: model, router: router)
        model.delegate = userVC
        return userVC
    }
    
    private func userModel() -> UserModelProtocol {
        return UserModel(userService: serviceAssembly.getUserService(for: .gcd))
    }
    
    // MARK: - ConversationsListViewController
    func conversationsListViewController(router: Router) -> ConversationsListViewController {
        let model = conversationsListModel()
        let converationsVC = ConversationsListViewController(router: router, model: model)
        model.delegate = converationsVC
        return converationsVC
    }
    
    private func conversationsListModel() -> ConversationsListModel {
        let userService = serviceAssembly.getUserService(for: .gcd)
        let channelsService = serviceAssembly.getChannelsService()
        return ConversationsListModel(channelsService: channelsService, userService: userService)
    }
    
    // MARK: - ConversationViewController
    func conversationViewController(channel: Channel, user: User, router: Router) -> ConversationViewController {
        let model = conversationModel(for: channel)
        let conversationVC = ConversationViewController(channel: channel, user: user, model: model)
        model.delegate = conversationVC
        return conversationVC
    }
    
    private func conversationModel(for channel: Channel) -> ConversationModelProtocol {
        return ConversationModel(messagesService: serviceAssembly.getMessagesService(for: channel))
    }
    
    // MARK: - ThemesViewController
    func themePickerViewController(delegate: ThemePickerDelegate, router: Router) -> ThemesViewController {
        let model = themePickerModel()
        let pickerVC = ThemesViewController(router: router, model: model)
        pickerVC.delegate = delegate
        model.delegate = pickerVC
        return pickerVC
    }
    
    private func themePickerModel() -> ThemePickerModelProtocol {
        return ThemePickerModel(themeService: serviceAssembly.getThemeService())
    }
    
    // MARK: - ImageLibrary
    func imageLibraryViewController() -> ImageLibraryViewController {
        let model = imageLibraryModel()
        let libraryVC = ImageLibraryViewController(model: model)
        model.delegate = libraryVC
        return libraryVC
    }
    
    private func imageLibraryModel() -> ImageLibraryModelProtocol {
        return ImageLibraryModel(libraryService: serviceAssembly.getOnlineImageLibrary())
    }

}
