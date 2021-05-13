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
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 25.0
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
                
        FirebaseApp.configure()
        
        // COREDATA VERSIONING
        let currentVersion = "1.2"
        let appVersion = UserDefaults.standard.string(forKey: "appVersion")
        if appVersion != currentVersion {
            CoreDataManager.shared.deleteEverything()
            UserDefaults.standard.setValue(currentVersion, forKey: "appVersion")
        }
        
        #if DEBUG
//        CoreDataManager.shared.deleteEverything()
        #endif
        
        // Initialise Authentication stuff
        if AuthManager.shared.initialize() {
//            PushNotificationManager.shared.checkPermissions()
//            PushNotificationManager.shared.registerForPushNotifications()
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
        #if DEBUG
//        CoreDataManager.shared.deleteEverything()
        #endif
        
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
