//
//  ChannelsFirebaseDataSource.swift
//  Chat
//
//  Created by Алексей Никитин on 25.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Firebase

fileprivate extension Channel {
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

fileprivate extension ChannelsChanges.Event {
    init(from: DocumentChangeType) {
        switch from {
        case .added:
            self = .create
        case .modified:
            self = .update
        case .removed:
            self = .delete
        }
    }
}

protocol ChannelsRepository: class {
    var refreshCallback: ([ChannelsChanges]) -> Void { get }
    
    func loadAllChannels(_ completion: @escaping([Channel]) -> Void)
    func createChannel(with name: String, _ completion: @escaping(Channel?, Error?) -> Void)
    func deleteChannel(with identifier: String, _ deleteCallback: @escaping(Error?) -> Void)
}

class ChannelsFirebaseDataSource: ChannelsRepository {
    private var listener: ListenerRegistration?
    private lazy var channelsRef: CollectionReference = {
        let db = Firestore.firestore()
        return db.collection(Channel.firebaseCollectionName)
    }()
    let refreshCallback: ([ChannelsChanges]) -> Void
    
    init(refresh: @escaping ([ChannelsChanges]) -> Void) {
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
    
    public func loadAllChannels(_ completion: @escaping ([Channel]) -> Void) {
        removeListener()
        var load = true
        listener = channelsRef.addSnapshotListener { [weak self] (docsSnapshot, _) in
            guard let self = self, let snapshot = docsSnapshot, snapshot.documentChanges.count > 0 else { return }
            
            if load {
                let channels = snapshot.documents.compactMap { Channel(from: $0.data(), id: $0.documentID) }
                completion(channels)
                load = false
            } else {
                let channels: [ChannelsChanges] = snapshot.documentChanges.compactMap { diff in
                    guard let channel = Channel(from: diff.document.data(), id: diff.document.documentID) else { return nil }
                    return ChannelsChanges(event: .init(from: diff.type), channel: channel)
                }
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
    
    public func deleteChannel(with identifier: String, _ deleteCallback: @escaping (Error?) -> Void) {
        channelsRef.document(identifier).delete(completion: deleteCallback)
    }
}
