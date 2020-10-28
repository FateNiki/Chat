//
//  CustomErrors.swift
//  Chat
//
//  Created by Алексей Никитин on 28.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

struct ErrorWithMessage: LocalizedError {
    var message: String
    
    var errorDescription: String? { message }
}
