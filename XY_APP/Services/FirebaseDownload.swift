//
//  FirebaseDownload.swift
//  XY_APP
//
//  Created by Maxime Franchot on 07/01/2021.
//

import Foundation
import Firebase

class FirebaseDownload {
    static func getProfile(userId: String, completion: @escaping(UpperProfile?, Error?) -> Void) {
        let userRef = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(userId)
        
        userRef.getDocument() { snapshot, error in
            if let error = error {
                completion(nil, error)
            }
            
            if let userData = snapshot?.data() as? [String: Any], let profileId = userData["profile"] as? String {
                let profileRef = userRef.collection(FirebaseKeys.CollectionPath.profile).document()
                profileRef.getDocument() { snapshot, error in
                    if let error = error {
                        completion(nil, error)
                    }
                    
                    if let profileData = snapshot?.data() as? [String: Any] {
                        
                        let profile = UpperProfile(
                            xyname: userData["xyname"] as! String,
                            imageId: profileData["image"] as! String,
                            website: profileData["website"] as! String,
                            followers: profileData["followers"] as! Int,
                            following: profileData["following"] as! Int,
                            xp: profileData["xp"] as! Int,
                            level: profileData["level"] as! Int,
                            caption: profileData["caption"] as! String)
    
                        completion(profile, nil)
                    }
                }
            }
        }
    }
}
