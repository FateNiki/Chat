//
//  ConversationsMock.swift
//  Chat
//
//  Created by Алексей Никитин on 26.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

let users: [User] = [
    User(firstName: "Ronald", lastName: "Robertson"),
    User(firstName: "Johnny", lastName: "Watson"),
    User(firstName: "Martha", lastName: "Craig"),
    User(firstName: "Arthur", lastName: "Bell"),
    User(firstName: "Jane", lastName: "Warren"),
    User(firstName: "Morris", lastName: "Henry"),
    User(firstName: "Irma", lastName: "Flores"),
    User(firstName: "Colin", lastName: "Williams")
]

func randomDate() -> Date {
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


func randomMessage() -> String {
    return Bool.random() ? "An suas viderer pro. Vis cu magna altera, ex his vivendo atomorum." : ""
}

let messages: [Message] = [
    Message(text: randomMessage(), date: randomDate(), isRead: Bool.random()),
    Message(text: randomMessage(), date: randomDate(), isRead: Bool.random()),
    Message(text: randomMessage(), date: randomDate(), isRead: Bool.random()),
    Message(text: randomMessage(), date: randomDate(), isRead: Bool.random()),
    Message(text: randomMessage(), date: randomDate(), isRead: Bool.random()),
    Message(text: randomMessage(), date: randomDate(), isRead: Bool.random()),
    Message(text: randomMessage(), date: randomDate(), isRead: Bool.random()),
    Message(text: randomMessage(), date: randomDate(), isRead: Bool.random()),
    Message(text: randomMessage(), date: randomDate(), isRead: Bool.random()),
    Message(text: randomMessage(), date: randomDate(), isRead: Bool.random()),
    Message(text: randomMessage(), date: randomDate(), isRead: Bool.random()),
    Message(text: randomMessage(), date: randomDate(), isRead: Bool.random())
]

let connversations: [Conversation] = users.map {
    Conversation(
        user: $0,
        lastMessage: messages.randomElement() ?? Message(text: "", date: Date(), isRead: true),
        isOnline: Bool.random()
    )
}
