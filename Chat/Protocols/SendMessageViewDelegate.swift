//
//  SendMessageViewDelegate.swift
//  Chat
//
//  Created by Алексей Никитин on 19.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

protocol SendMessageViewDelegate: class {
    func sendMessage(with text: String)
}
