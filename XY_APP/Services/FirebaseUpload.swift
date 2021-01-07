//
//  FirebaseUpload.swift
//  XY_APP
//
//  Created by Maxime Franchot on 07/01/2021.
//

import Foundation

import Firebase
import FirebaseStorage
import FirebaseAuth

class FirebaseUpload {
    
    static func editProfileInfo(profileData: UpperProfile, completion: @escaping(Result<Void, Error>) -> Void) {
        let uid = Auth.auth().currentUser!.uid
        let document = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(uid)
        document.getDocument() { snapshot, error in
            if let error = error {
                completion(.failure(error))
            }
            
            if let snapshot = snapshot, let profileId = snapshot.get("profile") as? String {
                let profile = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.profile).document(profileId)
                
                do {
                    profile.setData(profileData.editProfileData, merge: true) { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                        
                        completion(.success(()))
                    }
                } catch let error {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func changeProfileImage(profileImage: UIImage) {
        
    }
}
