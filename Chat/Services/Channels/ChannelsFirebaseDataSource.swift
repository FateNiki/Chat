//
//  ChannelsFirebaseDataSource.swift
//  Chat
//
//  Created by Алексей Никитин on 25.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Firebase

extension Channel {
    init?(from data: [String: Any], id: String) {
        guard let name = data["name"] as? String else {
            return nil
        }
        self.name = name
        self.identifier = id
        lastMessage = data["lastMessage"] as? String
        if let timestamp = data["lastActivity"] as? Timestamp {
            lastActivity = timestamp.dateValue()
        } else {
            lastActivity = nil
        }
    }
    
    var data: [String: Any] {
        ["name": name]
    }
    
    var timestamp: Double { lastActivity?.timeIntervalSince1970 ?? 0 }
}

class ChannelsFirebaseDataSource: ChannelsApiRepository {    
    private var listener: ListenerRegistration?
    private let refreshCallback: ([Channel]) -> Void
    private lazy var channelsRef: CollectionReference = {
        let db = Firestore.firestore()
        return db.collection(Channel.firebaseCollectionName)
    }()
    
    init(refresh: @escaping ([Channel]) -> Void) {
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
    
    public func loadChannels(_ completion: @escaping ([Channel]) -> Void) {
        removeListener()
        var load = true
        listener = channelsRef.addSnapshotListener { [weak self] (docsSnapshot, _) in
            guard let self = self, let snapshot = docsSnapshot, snapshot.documentChanges.count > 0 else { return }
            
            let channels = snapshot.documentChanges.compactMap { diff in
                Channel(from: diff.document.data(), id: diff.document.documentID)
            }
            
            if load {
                completion(channels)
                load = false
            } else {
                self.refreshCallback(channels)
            }
        }
    }
    
    public func createChannel(with name: String, _ completion: @escaping (Channel?, Error?) -> Void) {
        let newChannelRef = channelsRef.document()
        let newChannel = Channel(id: newChannelRef.documentID, name: name)
        newChannelRef.setData(newChannel.data) { (error) in
            if let error = error {
                completion(nil, error)
            } else {
                completion(newChannel, nil)
            }
        }
    }
}
