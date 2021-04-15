//
//  AppDelegate.swift
//  XY_APP
//
//  Created by Maxime Franchot on 17/11/2020.
//

import UIKit
import CoreData
import Firebase
import FirebaseMessaging
import IQKeyboardManagerSwift
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window:UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
                
        FirebaseApp.configure()
        
        // Initialise Authentication stuff
        if AuthManager.shared.isLoggedIn() {
    
//            _ProfileManager.shared.initialiseForCurrentUser() { error in
//                guard error == nil else {
//                    print("Error initializing profile data: \(error)")
//                    return
//                }
//                
//                OnlineStatusManager.shared.setupOnlineStatus()
//            }
//            
//            if let pushNotificationsEnabled = UserDefaults.standard.object(forKey: "pushNotificationsEnabled") as? Bool,
//               pushNotificationsEnabled {
//                let pushNotificationsManager = PushNotificationManager.init(userID: AuthManager.shared.userId!)
//                pushNotificationsManager.checkPermissions()
//                pushNotificationsManager.registerForPushNotifications()
//            }
//            
//            FlowAlgorithmManager.shared.initialiseFollowing()
//            
//            ActionManager.shared.getActions()
//            
//            if UserDefaults.standard.object(forKey: "flowRefreshIndex") != nil {
//                let index = UserDefaults.standard.integer(forKey: "flowRefreshIndex")
//                PostManager.shared.userPostIndex = index
//            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Application launch from notification with context
        
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var readableToken: String = ""
          for i in 0..<deviceToken.count {
            readableToken += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
          }
          print("Received an APNs device token: \(readableToken)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
//        CoreDataManager.shared.deleteEverything()
        
        saveContext()
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = CoreDataManager.shared.mainContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
