//
//  DataProtocol.swift
//  Chat
//
//  Created by Алексей Никитин on 10.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

protocol DataManager {
    associatedtype ManagerData
    associatedtype ManagerResult
    
    func loadFromFile(completion: ((ManagerResult) -> Void)?)
    func saveToFile(data: ManagerData, completion: ((ManagerResult) -> Void)?)
}
