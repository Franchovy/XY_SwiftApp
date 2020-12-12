//
//  AppDelegate.swift
//  XY_APP
//
//  Created by Maxime Franchot on 17/11/2020.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window:UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Check user session 
        // Check login
        if Session.hasSession() {
            print("Session active!")
        } else {
            print("Checking session...")
            
            let sessionIsLoaded = CoreDataManager.loadSession()
            if sessionIsLoaded {
                print("Session loaded! Skipping login screen.")
                loadInitialScreenOnAuthCheck()
            } else {
                // No session detected locally.
                // Check backend for session
                Session.requestSession(completion: { result in
                    switch result {
                    case .success(let message):
                        print("Received session info from backend. Setting local session.")
                        if let username = message.username {
                            Session.username = username
                        }
                        if let token = message.token {
                            Session.sessionToken = token
                        }
                    case .failure(let error):
                        print("No session found, or error: \(error)")
                    }
                    
                    // Load initial screen after check
                    self.loadInitialScreenOnAuthCheck()
                })
            }
        }
        
        if #available(iOS 13.0, *) {
            // In iOS 13 setup is done in SceneDelegate
        } else {

        }
        
        return true
    }
    
    func loadInitialScreenOnAuthCheck() {
        // Set initial view in ios version 12
        if #available(iOS 13.0, *) {
            
        } else {
            let window = UIWindow(frame: UIScreen.main.bounds)
            self.window = window

            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            if (Session.hasSession()){
                let newViewcontroller:UIViewController = mainstoryboard.instantiateViewController(withIdentifier: "MainViewController") as! UITabBarController
                window.rootViewController = newViewcontroller
            } else {
                
                let newViewcontroller:UIViewController = mainstoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                window.rootViewController = newViewcontroller
            }
        }
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "XY_APP")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            // Persistent store loaded
            print("Load persistent stores test")
            
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

