//
//  OnlineStatusManager.swift
//  XY
//
//  Created by Maxime Franchot on 03/02/2021.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

final class OnlineStatusManager {
    static let shared = OnlineStatusManager()
    private init() { }
    
    public func setupOnlineStatus() {
        guard let user = Auth.auth().currentUser else { return }

        // get user branch of database
        let ref = Database.database().reference()
        let usersRef = ref.child("OnlineNow")
        let userRef = usersRef.child(user.uid)

        
        // set "isOnline" branch to true when app launches
        userRef.child("online").setValue(true) { error, databaseReference in
            if let error = error {
                print("Error setting online value: \(error)")
            } else {
                print(databaseReference)
            }
        }
        
        userRef.onDisconnectRemoveValue()
    }
}
