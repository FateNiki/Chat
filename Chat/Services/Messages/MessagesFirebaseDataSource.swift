//
//  MessagesFirebaseDataSource.swift
//  Chat
//
//  Created by Алексей Никитин on 26.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Firebase

extension Message {
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
    
    var timestamp: Double { created.timeIntervalSince1970 }
}

class MessagesFirebaseDataSource {
    private var messages = [Message]()
    private var listener: ListenerRegistration?
    private let refreshCallback: ([Message]) -> Void
    private var messagesRef: CollectionReference
    
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
        print("REMOVE \(String(describing: Message.self))")
        listener.remove()
        self.listener = nil
    }
    
    private func setMessages(from snapshot: QuerySnapshot) {
        self.messages = snapshot.documents.compactMap { docSnapshot in
            Message(from: docSnapshot.data())
        }.sorted { $0.timestamp < $1.timestamp }
    }
    
    public func loadChannels(_ completion: @escaping ([Message]) -> Void) {
        removeListener()
        var load = true
        listener = messagesRef.addSnapshotListener { [weak self] (docsSnapshot, _) in
            guard let self = self, let snapshot = docsSnapshot, snapshot.documentChanges.count > 0 else { return }
            self.setMessages(from: snapshot)
            
            if load {
                print("LOAD \(String(describing: Message.self))")
                completion(self.messages)
                load = false
            } else {
                print("UPDATE \(String(describing: Message.self))")
                self.refreshCallback(self.messages)
            }
        }
    }
    
    func createMessage(_ message: Message, _ errorCallback: @escaping (Error) -> Void) {
        messagesRef.addDocument(data: message.data) { error in
            if let error = error { errorCallback(error) }
        }
    }
    
}
