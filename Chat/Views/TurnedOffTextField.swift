//
//  TurnedOffTextField.swift
//  Chat
//
//  Created by Алексей Никитин on 10.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class TurnedOffTextField: UITextField {
    override var isEnabled: Bool {
        didSet {
            borderStyle = isEnabled ? .roundedRect : .none
        }
    }
}
