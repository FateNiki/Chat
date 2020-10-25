//
//  FirebaseDataSource.swift
//  Chat
//
//  Created by Алексей Никитин on 18.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Firebase

protocol FirebaseElement {
    init?(from data: [String: Any], id: String)
    
    var data: [String: Any] { get }
    
    var timestamp: Double { get }
}

class FirebaseDataSource<Element> where Element: FirebaseElement {
    private let collectionsQuery: Query    
    private weak var tableView: UITableView!
    private(set) var elements = [Element]()
    private var listener: ListenerRegistration?
    private let refreshCallback: (() -> Void)?
    
    init(for tableView: UITableView, with query: Query, refresh: (() -> Void)?) {
        self.tableView = tableView
        self.collectionsQuery = query
        self.refreshCallback = refresh
        createListener()
    }
    
    private func createListener() {
        listener = collectionsQuery.addSnapshotListener { [weak self] (docsSnapshot, _) in
            guard let snapshot = docsSnapshot, snapshot.documentChanges.count > 0 else { return }
            
            self?.elements = snapshot.documents.compactMap { docSnapshot in
                Element(from: docSnapshot.data(), id: docSnapshot.documentID)
            }
            
//            self?.updateTable(by: snapshot)
            self?.updateTable()
        }
    }
        
    deinit {
        print("REMOVE \(String(describing: type(of: Element.self)))")
        listener?.remove()
        listener = nil
    }
    
    // Для обновления без полной перзагрузки
    private func updateTable(by snapshot: QuerySnapshot) {
        print("UPDATE \(String(describing: type(of: Element.self)))")
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
        refreshCallback?()
    }
    
    private func updateTable() {
        print("RELOAD \(String(describing: type(of: Element.self)))")
        elements.sort { $0.timestamp > $1.timestamp }
        tableView.reloadData()
        refreshCallback?()
    }
}

fileprivate extension IndexPath {
    init(for index: UInt) {
        self.init(row: Int(index), section: 0)
    }
}
