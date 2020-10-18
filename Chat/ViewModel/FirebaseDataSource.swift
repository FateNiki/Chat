//
//  FirebaseDataSource.swift
//  Chat
//
//  Created by Алексей Никитин on 18.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Firebase

protocol FromData {
    init?(_ id: String, from data: [String: Any])
}

extension Channel: FromData {
    init?(_ id: String, from data: [String: Any]) {
        guard let name = data["name"] as? String else {
            return nil
        }
        self.name = name
        identifier = id
        lastMessage = data["lastMessage"] as? String
        lastActivity = data["lastActivity"] as? Date
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
            print("UPDATE")
            guard let snapshot = docsSnapshot, snapshot.documentChanges.count > 0 else { return }
            guard let tableView = self?.tableView else { return }
            
            self?.elements = snapshot.documents.map { docSnapshot in
                Element(docSnapshot.documentID, from: docSnapshot.data())
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
            
            snapshot.documentChanges.forEach { diff in
                if diff.type == .modified && diff.newIndex != diff.oldIndex {
                    tableView.moveRow(at: IndexPath(for: diff.oldIndex), to: IndexPath(for: diff.newIndex))
                }
            }
            tableView.endUpdates()
        }
    }
        
    deinit {
        print("REMOVE")
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
