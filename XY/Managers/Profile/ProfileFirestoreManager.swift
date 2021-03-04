//
//  ProfileFirestoreManager.swift
//  XY
//
//  Created by Maxime Franchot on 04/03/2021.
//

import Foundation

class ProfileFirestoreManager {
    static var shared = ProfileFirestoreManager()
    private init() { }
    
    func getProfileID(forUserID userID: String, completion: @escaping(String?, Error?) -> Void) {
        let userRef = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(userID)
        
        userRef.getDocument() { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(nil, error)
                return
            }
            
            if let userData = snapshot.data() as? [String: Any] {
                let profileId = userData[FirebaseKeys.UserKeys.profile] as! String
                completion(profileId, nil)
            }
        }
    }
    
    
    func getProfile(forProfileID profileID: String, completion: @escaping(ProfileModel?) -> Void) {
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.profile)
            .document(profileID)
            .getDocument { (snapshot, error) in
                if let error = error {
                    print(error)
                    completion(nil)
                } else if let snapshot = snapshot, let data = snapshot.data() {
                    completion(ProfileModel(data: data, id: snapshot.documentID))
                }
            }
    }
}
