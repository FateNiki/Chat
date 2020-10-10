//
//  TurnedOffTextField.swift
//  Chat
//
//  Created by Алексей Никитин on 10.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class TurnedOffTextField: UITextField {
    var inEditing: Bool = true {
        didSet {
            borderStyle = inEditing ? .roundedRect : .none
            isUserInteractionEnabled = inEditing
        }
    }
}
