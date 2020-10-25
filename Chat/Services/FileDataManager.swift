//
//  DataProtocol.swift
//  Chat
//
//  Created by Алексей Никитин on 10.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

protocol FileDataManager {
    associatedtype ManagerData
    associatedtype ManagerResult
    associatedtype ManagerError
    
    func loadFromFile(completion: ((ManagerResult?, ManagerError?) -> Void)?)
    func saveToFile(data: ManagerData, completion: ((ManagerResult?, ManagerError?) -> Void)?)
}
