//
//  MessagesFirebaseDataSource.swift
//  Chat
//
//  Created by Алексей Никитин on 26.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Firebase

fileprivate extension Message {
    init?(from data: [String: Any], id: String) {
        guard let content = data["content"] as? String,
              let created = data["created"] as? Timestamp,
              let senderId = data["senderId"] as? String,
              let senderName = data["senderName"] as? String
        else { return nil }
        self.identifier = id
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
        self.loadMessages()
        
    }
    
    deinit {
        removeListener()
    }
    
    private func removeListener() {
        guard let listener = listener else { return }
        listener.remove()
        self.listener = nil
    }
    
    private func loadMessages() {
        removeListener()
        listener = messagesRef.addSnapshotListener { [weak self] (docsSnapshot, _) in
            guard let self = self, let snapshot = docsSnapshot, snapshot.documentChanges.count > 0 else { return }
            
            let newMessages = snapshot.documentChanges.filter { $0.type == .added }.compactMap { Message(from: $0.document.data(), id: $0.document.documentID) }
            self.refreshCallback(newMessages)
        }
    }
    
    func createMessage(from sender: User, with text: String, _ errorCallback: @escaping (Error) -> Void) {
        let newMessageRef = messagesRef.document()
        let newMessage = Message(id: newMessageRef.documentID, content: text, senderId: sender.id, senderName: sender.fullName)
        newMessageRef.setData(newMessage.data) { error in
            if let error = error { errorCallback(error) }
        }
    }
    
}
