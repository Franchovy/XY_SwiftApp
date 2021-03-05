//
//  DatabaseManager.swift
//  XY
//
//  Created by Maxime Franchot on 03/02/2021.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()
    private init() { }
    
    private var databaseReference = Database.database().reference()
    
    // Returns user and profile IDs live in the realtime database
    public func subscribeToOnlineNow(completion: @escaping([(String, String)]?) -> Void) {
        let onlineNowRef = databaseReference.child("OnlineNow")
        
        let onlineNowHandle = onlineNowRef.observe(DataEventType.value, with: { (snapshot) in
            if let newValues = snapshot.value as? [String : [String: String]] {
                var activeUserIds = [(String, String)]()
                for value in newValues {
                    if let profileId = value.value["profile"] {
                        activeUserIds.append((value.key, profileId))
                    }
                }
                completion(activeUserIds)
            } else {
                completion([])
            }
        })
    }
}
