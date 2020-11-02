//
//  MessagesFirebaseDataSource.swift
//  Chat
//
//  Created by Алексей Никитин on 26.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Firebase

fileprivate extension Message {
    init?(from data: [String: Any]) {
        guard let content = data["content"] as? String,
              let created = data["created"] as? Timestamp,
              let senderId = data["senderId"] as? String,
              let senderName = data["senderName"] as? String
        else { return nil }
        self.content = content
        self.created = created.dateValue()
        self.senderId = senderId
        self.senderName = senderName
    }
    
    var data: [String: Any] {[
        "content": content,
        "created": Timestamp(date: created),
        "senderId": senderId,
        "senderName": senderName
    ]}
}

class MessagesFirebaseDataSource: MessagesApiRepository {
    private var listener: ListenerRegistration?
    private var messagesRef: CollectionReference
    private let refreshCallback: ([Message]) -> Void
    
    init(for channel: Channel, refresh: @escaping ([Message]) -> Void) {
        let db = Firestore.firestore()
        self.messagesRef = db.collection(Channel.firebaseCollectionName)
            .document(channel.identifier)
            .collection(Message.firebaseCollectionName)
        self.refreshCallback = refresh
        
    }
    
    deinit {
        removeListener()
    }
    
    private func removeListener() {
        guard let listener = listener else { return }
        listener.remove()
        self.listener = nil
    }
    
    public func loadMessages(after message: Message?) {
        removeListener()
        var queryRef: Query = messagesRef
        if let message = message {
            queryRef = queryRef.whereField("created", isGreaterThan: Timestamp(date: message.created.addingTimeInterval(1)))
        }
        listener = queryRef.addSnapshotListener { [weak self] (docsSnapshot, _) in
            guard let self = self, let snapshot = docsSnapshot, snapshot.documentChanges.count > 0 else { return }
            
            let newMessages = snapshot.documentChanges.filter { $0.type == .added }.compactMap { Message(from: $0.document.data()) }
            self.refreshCallback(newMessages)
        }
    }
    
    func createMessage(_ message: Message, _ errorCallback: @escaping (Error) -> Void) {
        messagesRef.addDocument(data: message.data) { error in
            if let error = error { errorCallback(error) }
        }
    }
    
}
