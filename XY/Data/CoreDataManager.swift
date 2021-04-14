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
    private init() {}
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Challenge")
        container.loadPersistentStores(completionHandler: { _, error in
            _ = error.map { print("Unresolved error \($0)") }
        })
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func backgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    func deleteEverything() {
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
        } catch let error as NSError {
            print(error)
        }
        
    }
}
