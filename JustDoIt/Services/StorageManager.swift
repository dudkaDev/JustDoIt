//
//  StorageManager.swift
//  JustDoIt
//
//  Created by Андрей Абакумов on 01.02.2023.
//

import CoreData

class StorageManager {
    static let shared = StorageManager()
    
    //MARK: - Core Data stack
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "JustDoIt")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
                return container
    }()
    
    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {}
    
    //MARK: - Core Data Saving support
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func getFetcherResultsController(entityName: String, keyForSort: String) -> NSFetchedResultsController <NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: keyForSort, ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        return fetchResultsController
    }
    
    func saveTask(withTitle title: String, andPriority priority: Int16) {
        let task = Task(context: viewContext)
        task.title = title
        task.priority = priority
        task.date = Date()
        saveContext()
    }
    
    func delete(task: Task) {
        viewContext.delete(task)
        saveContext()
    }
    
    func edit(task: Task, with newTitle: String, and priority: Int16) {
        task.title = newTitle
        task.priority = priority
        saveContext()
    }
}

