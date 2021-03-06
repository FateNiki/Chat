//
//  CoreDataStack.swift
//  Chat
//
//  Created by Алексей Никитин on 23.10.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    // MARK: - Singleton
    static let shared = CoreDataStack()
    private init() { }
    
    func config(_ completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.addPersistentStoreToCoordinator()
            DispatchQueue.main.async(execute: completion)
        }
    }
    
    // MARK: - Constants
    private let dataModelName = "Chat"
    private let dataModelExtension = "momd"
    private var storeUrl: URL = {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            fatalError("document path not found")
        }
        return documentsUrl.appendingPathComponent("Chat.sqlite")
    }()
    
    // MARK: - Init Stack
    private(set) lazy var managedObjectModel: NSManagedObjectModel = {
        guard let moduleUrl = Bundle.main.url(forResource: dataModelName, withExtension: dataModelExtension) else {
            fatalError("module not found")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: moduleUrl) else {
            fatalError("managedObjectModel could not be created")
        }
        return managedObjectModel
    }()
    
    private lazy var persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    
    private func addPersistentStoreToCoordinator() {
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    // MARK: - Contexts
    private lazy var writterContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        context.mergePolicy = NSOverwriteMergePolicy
        return context
    }()
    
    private(set) lazy var mainContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = writterContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return context
    }()
    
    private func saveContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = mainContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    // MARK: - Save
    func performSave(_ block: (NSManagedObjectContext) -> Void) {
        let context = saveContext()
        context.performAndWait {
            block(context)
            if context.hasChanges {
                do {
                    try context.obtainPermanentIDs(for: Array(context.insertedObjects))
                    try performSave(in: context)                    
                } catch { assertionFailure(error.localizedDescription)}
            }
        }
        
    }
    
    private func performSave(in context: NSManagedObjectContext) throws {
        try context.save()
        if let parent = context.parent {
            try performSave(in: parent)
        }
    }

}
