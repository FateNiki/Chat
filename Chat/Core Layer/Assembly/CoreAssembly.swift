//
//  CoreAssembly.swift
//  Chat
//
//  Created by Алексей Никитин on 09.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

protocol CoreAssemblyProtocol {    
    var userCGDStorage: UserStorageProtocol { get }
    var userOperationsStorage: UserStorageProtocol { get }
}

class CoreAssembly: CoreAssemblyProtocol {
    lazy var userCGDStorage: UserStorageProtocol = GCDUserStorage.shared
    lazy var userOperationsStorage: UserStorageProtocol = OperationsUserStorage.shared
}
