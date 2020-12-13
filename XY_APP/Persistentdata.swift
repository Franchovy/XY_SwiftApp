//
//  Persistentdata.swift
//  XY_APP
//
//  Created by Maxime Franchot on 12/12/2020.
//

import CoreData

import UIKit
import CoreData
import Foundation



class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "XY_APP") // Load XY_APP datamodel
        container.loadPersistentStores(completionHandler: { _, error in
            _ = error.map { fatalError("Error: \($0)") }
        })
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func backgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    static func loadSession() -> Bool {
        let mainContext = CoreDataManager.shared.mainContext
        
        do {
            // load code
            let extractValues: [PersistentSession]
            
            let request = PersistentSession.fetchRequest2()
            request.returnsObjectsAsFaults = false
            do
            {
                extractValues = try mainContext.fetch(request)
            }
            catch { fatalError("Could not load Data") }
            
            if let session = extractValues.first {
                print("Session data: \(session)")
                if let username = session.username, let token = session.token {
                    Session.username = session.username!
                    Session.sessionToken = session.token!
                    Session.expiryTime = session.expiry ?? Date()
                } else {
                    print("No Session data!")
                }
            } else {
                print("Could not find session in coredata")
            }
            
            return true
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return false
        }
    }
    
    static func saveSession() throws {
        let mainContext = CoreDataManager.shared.mainContext
        
        // Remove existing sessions
        try? deleteSessionsFromContext()
        
        // Create new session inside main context
        let persistentSession = PersistentSession(context: mainContext)
        
        persistentSession.username = Session.username
        persistentSession.token = Session.sessionToken
        persistentSession.expiry = Session.expiryTime
        
        do
        {
            try mainContext.save()
            print("Saved new session into persistent context.")
        }
        catch { fatalError("Unable to save data.") }
    }
    
    static func removeSession() {
        try? deleteSessionsFromContext()
    }
    
    fileprivate static func deleteSessionsFromContext() throws {
        let mainContext = CoreDataManager.shared.mainContext
        
        // Remove existing sessions
        do {
            let sessionsExisting: [PersistentSession]
            let fetchRequest = PersistentSession.fetchRequest2()
            sessionsExisting = try mainContext.fetch(fetchRequest)
            for session in sessionsExisting {
                print("Deleting session: \(session) ...")
                mainContext.delete(session)
            }
            try mainContext.save()
            print("Deleted previous session(s).")
        } catch {
            print("No previous session(s) to remove")
        }
    }
}
