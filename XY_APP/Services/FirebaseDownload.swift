//
//  FirebaseDownload.swift
//  XY_APP
//
//  Created by Maxime Franchot on 07/01/2021.
//

import Foundation
import Firebase
import FirebaseStorage

class FirebaseDownload {
    static func getProfile(userId: String, completion: @escaping(UpperProfile?, Error?) -> Void) {
        let userRef = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(userId)
        
        userRef.getDocument() { snapshot, error in
            if let error = error {
                completion(nil, error)
            }
            
            if let userData = snapshot?.data() as? [String: Any], let profileId = userData["profile"] as? String {
                let profileRef = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.profile).document(profileId)
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
    
    static func getImage(imageId: String, completion: @escaping(UIImage?, Error?) -> Void) {
        let storage = Storage.storage()
        
        let imageRef = storage.reference(withPath: imageId)
        imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                completion(nil, error)
            }
            if let data = data, let image = UIImage(data: data) {
                completion(image, nil)
            }
        }
    }
    
    // static func get flow [range of int] posts to get within algorithm
}
