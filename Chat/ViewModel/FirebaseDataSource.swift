//
//  FirebaseDataSource.swift
//  Chat
//
//  Created by Алексей Никитин on 18.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Firebase

protocol FromData {
    init?(from data: [String: Any], id: String)
}

extension Channel: FromData {
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
}

extension Message: FromData {
    init?(from data: [String: Any], id: String) {
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
}

class FirebaseDataSource<Element> where Element: FromData {
    private let collectionsQuery: Query    
    private weak var tableView: UITableView!
    private(set) var elements = [Element?]()
    private var listener: ListenerRegistration?
    
    init(for tableView: UITableView, with query: Query) {
        self.tableView = tableView
        collectionsQuery = query
        createListener()
    }
    
    private func createListener() {
        listener = collectionsQuery.addSnapshotListener { [weak self] (docsSnapshot, _) in
            print("UPDATE \(String(describing: type(of: Element.self)))")
            guard let snapshot = docsSnapshot, snapshot.documentChanges.count > 0 else { return }
            guard let tableView = self?.tableView else { return }
            
            self?.elements = snapshot.documents.map { docSnapshot in
                Element(from: docSnapshot.data(), id: docSnapshot.documentID)
            }
            
            tableView.beginUpdates()
            let addedIndeces = snapshot.documentChanges.filter({ $0.type == .added }).map({ IndexPath(for: $0.newIndex) })
            if addedIndeces.count > 0 {
                tableView.insertRows(at: addedIndeces, with: .automatic)
            }
            
            let removedIndeces = snapshot.documentChanges.filter({ $0.type == .removed }).map({ IndexPath(for: $0.newIndex) })
            if removedIndeces.count > 0 {
                tableView.deleteRows(at: removedIndeces, with: .automatic)
            }
            
            let updatedIndeces = snapshot.documentChanges.filter({ $0.type == .modified }).map({ IndexPath(for: $0.newIndex) })
            if updatedIndeces.count > 0 {
                tableView.reloadRows(at: updatedIndeces, with: .automatic)
            }
            
            snapshot.documentChanges.forEach { diff in
                if diff.type == .modified && diff.newIndex != diff.oldIndex {
                    tableView.moveRow(at: IndexPath(for: diff.oldIndex), to: IndexPath(for: diff.newIndex))
                }
            }
            tableView.endUpdates()
        }
    }
        
    deinit {
        print("REMOVE \(String(describing: type(of: Element.self)))")
        listener?.remove()
        listener = nil
    }
    
    private func indexPath(for index: UInt) -> IndexPath {
        IndexPath(row: Int(index), section: 0)
    }
}

fileprivate extension IndexPath {
    init(for index: UInt) {
        self.init(row: Int(index), section: 0)
    }
}
