//
//  CoreDataStack.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import CoreData
import Foundation

/// Core Data stack for persistent storage
class CoreDataStack {

    /// Shared singleton instance
    static let shared = CoreDataStack()

    /// Container name (matches .xcdatamodeld file name)
    private let modelName = "DailyQuipAIModel"

    /// Persistent container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // In production, handle this error appropriately
                // For now, we'll use fatalError as this is critical
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        // Enable automatic merging of changes from parent
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }()

    /// Main thread view context
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    /// Private initializer for singleton
    private init() {}

    /// Create a new background context for performing operations off the main thread
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    /// Save the view context if it has changes
    /// - Throws: Core Data save error
    func saveContext() throws {
        let context = viewContext
        if context.hasChanges {
            try context.save()
        }
    }

    /// Save a background context if it has changes
    /// - Parameter context: The context to save
    /// - Throws: Core Data save error
    func saveContext(_ context: NSManagedObjectContext) throws {
        if context.hasChanges {
            try context.save()
        }
    }

    /// Perform a block on a background context and save
    /// - Parameter block: The block to perform
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) throws -> Void) async throws {
        let context = newBackgroundContext()

        try await context.perform {
            try block(context)
            if context.hasChanges {
                try context.save()
            }
        }
    }
}

// MARK: - Testing Support
#if DEBUG
extension CoreDataStack {
    /// Create an in-memory stack for testing
    static func createInMemoryStack() -> CoreDataStack {
        let stack = CoreDataStack()

        let container = NSPersistentContainer(name: stack.modelName)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }

        // Override the lazy var with our in-memory container
        stack.persistentContainer = container

        return stack
    }
}
#endif
