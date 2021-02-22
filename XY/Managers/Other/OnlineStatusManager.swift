//
//  OnlineStatusManager.swift
//  XY
//
//  Created by Maxime Franchot on 03/02/2021.
//

import Foundation
import FirebaseDatabase

final class OnlineStatusManager {
    static let shared = OnlineStatusManager()
    private init() { }
    
    public func setupOnlineStatus() {
        guard let userId = AuthManager.shared.userId else { fatalError() }
        
        // get user branch of database
        let ref = Database.database().reference()
        let usersRef = ref.child("OnlineNow")
        let userRef = usersRef.child(userId)

        ProfileManager.shared.initialiseForCurrentUser() { error in
            guard error == nil else {
                print("Error initializing profile data: \(error)")
                return
            }
            if let profileId = ProfileManager.shared.ownProfileId {
                
                // BLOCK ONLINE NOW ON THE DEV DB
                if FirestoreReferenceManager.environment == "dev" {
                    return
                }
                
                userRef.child("profile").setValue(profileId) { error, databaseReference in
                    if let error = error {
                        print("Error setting online value: \(error)")
                    } else {
                        print(databaseReference)
                    }
                }
            }
        }
        
        userRef.onDisconnectRemoveValue()
    }
}
