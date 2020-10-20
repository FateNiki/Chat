//
//  SafeArray.swift
//  Chat
//
//  Created by Алексей Никитин on 13.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

class SafeArray<Element> {
    private var array: [Element] = []
    private let accessQueue = DispatchQueue(label: "SyncArrayAccess", attributes: .concurrent)
    
    var value: [Element] {
        var value: [Element] = []
        accessQueue.sync {
            value = array
        }
        return value
    }
    
    func append(_ newElement: Element) {
        accessQueue.async(flags: .barrier) {
            self.array.append(newElement)
        }
    }
    
    func reset() {
        accessQueue.async(flags: .barrier) {
            self.array.removeAll()
        }
    }
}
