//
//  PushNotificationSender.swift
//  XY
//
//  Created by Maxime Franchot on 16/02/2021.
//

import Foundation

class PushNotificationSender {
    func sendPushNotification(to userId: String, title: String, body: String) {
        
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(userId).getDocument { (snapshot, error) in
            if let error = error {
                print(error)
            } else if let snapshot = snapshot, let data = snapshot.data() {
                if let token = data[FirebaseKeys.UserKeys.fcmToken] as? String {
                    // Run notification API task
                    let urlString = "https://fcm.googleapis.com/fcm/send"
                    let url = NSURL(string: urlString)!
                    let paramString: [String : Any] = ["to" : token,
                                                       "notification" : ["title" : title, "body" : body],
                                                       "data" : ["user" : "test_id"]
                    ]
                    let request = NSMutableURLRequest(url: url as URL)
                    request.httpMethod = "POST"
                    request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("key=AAAAQF-Aw8o:APA91bH6ZkEZHaiSGf1nhyYi5H_GUMypmOXeMAcaO66XX662dS1EjH0HoR9bSnJmblWhp6YdcYvpW7O2NBj4V3GmGfa_YdSGyCAAXnshrAdD4LfNx7Kl0zpADzvPCrnfuPef_RE-gKtj", forHTTPHeaderField: "Authorization")
                    let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
                        do {
                            if let jsonData = data {
                                if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                                    NSLog("Received data:\n\(jsonDataDict))")
                                }
                            }
                        } catch let err as NSError {
                            print(err.debugDescription)
                        }
                    }
                    task.resume()
                }
            }
        }
    }
}
