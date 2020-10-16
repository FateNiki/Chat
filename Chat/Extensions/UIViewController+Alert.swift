//
//  UIViewController+Alert.swift
//  Chat
//
//  Created by Алексей Никитин on 22.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

extension UIViewController {
    func openAlert(title: String, message: String) {
        let errorAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        errorAlertController.addAction(UIAlertAction(title: "Закрыть", style: .cancel))
        present(errorAlertController, animated: true)
    }
    
    func openAlert(title: String, message: String, buttons: [UIAlertAction]) {
        let errorAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for button in buttons {
            errorAlertController.addAction(button)
        }
        present(errorAlertController, animated: true)
    }
}
