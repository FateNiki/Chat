//
//  MessageMock.swift
//  Chat
//
//  Created by Алексей Никитин on 28.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

private let messages = [
    "Test message 1",
    "Test message 2",
    "Test message 3",
    "Test message 4",
    "Test message 5",
    "Test message 6",
    "Test message 7",
    "Test message 8",
    "Test message 9",
    "Test message 10",
    "Test message 11",
    "An suas viderer pro. Vis cu magna altera, ex his vivendo atomorum.",
    "Vis cu magna altera, ex his vivendo atomorum. An suas viderer pro.",
]

private func randomDate() -> Date {
    let delta = Int.random(in: -10...0)
    let now = Date()
    var component: Calendar.Component
    switch Int.random(in: 0...2) {
        case 0: component = .day
        case 1: component = .hour
        default: component = .minute
    }
    return Calendar.current.date(byAdding: component, value: delta, to: now) ?? now
}

func createMessage(with text: String) -> Message {
    let date = randomDate()
    let direction: Message.Direction = Bool.random() ? .income : .outcome
    let isRead: Bool = direction == .income ? Bool.random() : true
    return Message(text: text, date: date, direction: direction, isRead: isRead)
}

let mockMessages: [Message] = messages.map { createMessage(with: $0) }.sorted {
    return $0.date.timeIntervalSince1970 > $1.date.timeIntervalSince1970
}


let conversationsMock: [Conversation] = mockUsers.map {
    let message: String = Bool.random() ? messages.randomElement() ?? "" : ""
    let isRead: Bool = message.isEmpty ? true : Bool.random()
    return Conversation(
        user: $0,
        lastMessage: Message(text: message, date: randomDate(), direction: .income, isRead: isRead),
        isOnline: message.isEmpty ? true : Bool.random()
    )
}
