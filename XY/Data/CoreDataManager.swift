//
//  CoreDataManager.swift
//  XY
//
//  Created by Maxime Franchot on 14/04/2021.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {
        
    }
    
    var isSetup = false
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Challenge")
        container.loadPersistentStores(completionHandler: { _, error in
            _ = error.map { print("Unresolved error \($0)") }
        })
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        if !isSetup {
            performSetup()
        }
        
        return persistentContainer.viewContext
    }
    
    func backgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    func performOnBackgroundThreadAndSave(block: @escaping((NSManagedObjectContext) -> Void), completion: @escaping(() -> Void)) {
        let context = backgroundContext()
        context.perform {
            block(context)
            
            do {
                try context.save()
            } catch let error {
                fatalError(error.localizedDescription)
            }
            
            completion()
        }
    }
    
    @objc func save() {
        do {
            try persistentContainer.viewContext.save()
        } catch let error {
            
            fatalError(error.localizedDescription)
        }
    }
    
    func performSetup() {
        isSetup = true
        
        persistentContainer.viewContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
    }
    
    func deleteEverything() {
        if !isSetup {
            performSetup()
        }
        // Delete challenges
        let challengeFetchRequest: NSFetchRequest<NSFetchRequestResult> = ChallengeDataModel.fetchRequest()
        let challengeDeleteRequest = NSBatchDeleteRequest(fetchRequest: challengeFetchRequest)
        
        // Delete all users/friends
        let friendsFetchRequest: NSFetchRequest<NSFetchRequestResult> = UserDataModel.fetchRequest()
        let friendsDeleteRequest = NSBatchDeleteRequest(fetchRequest: friendsFetchRequest)

        // perform the delete
        do {
            try persistentContainer.viewContext.execute(challengeDeleteRequest)
            try persistentContainer.viewContext.execute(friendsDeleteRequest)
            
            save()
        } catch let error as NSError {
            print(error)
        }
        
    }
}
