//
//  PushNotificationsManager.swift
//  XY
//
//  Created by Maxime Franchot on 16/02/2021.
//

import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications

class PushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    static var shared: PushNotificationManager?
        
    let userID: String
    init(userID: String) {
        self.userID = userID
        
        super.init()
        
        PushNotificationManager.shared = self
    }

    func arePushNotificationsEnabled(completion: @escaping(Bool) -> Void) {
        
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings(completionHandler: { permission in
            switch permission.authorizationStatus  {
            case .authorized:
                print("Authorized")
                completion(true)
            case .denied:
                print("Denied")
                completion(false)
            case .notDetermined:
                print("Not Determined")
                completion(false)
            case .provisional:
                print("Provisional")
                completion(true)
            case .ephemeral:
                print("Ephemeral")
                completion(true)
            @unknown default:
                print("Unknown Status")
            }
        })
    }
    
    func checkPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            
          print("Alert setting is \(settings.alertSetting == UNNotificationSetting.enabled ? "enabled" : "disabled")")
          print("Sound setting is \(settings.soundSetting == UNNotificationSetting.enabled ? "enabled" : "disabled")")
        }
    }
    
    func registerForPushNotifications() {
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }

        UIApplication.shared.registerForRemoteNotifications()
        updateFirestorePushTokenIfNeeded()
    }

    func updateFirestorePushTokenIfNeeded() {
        if let token = Messaging.messaging().fcmToken {
            
            print("FCM Token: \(String(describing: token))")
            let usersRef = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(userID)
            usersRef.setData([FirebaseKeys.UserKeys.fcmToken: token], merge: true)
        }
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        updateFirestorePushTokenIfNeeded()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User Notification Center: ", response)
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification will show: \(notification)")
    }
}
