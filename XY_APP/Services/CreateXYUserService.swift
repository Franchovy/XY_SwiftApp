//
//  CreateUserService.swift
//  XY_APP
//
//  Created by Maxime Franchot on 07/01/2021.
//

import Foundation
import FirebaseAuth
import Firebase

class CreateXYUserService {
    
    static func createUser(xyname: String, email: String?, phoneNumber: String?, password: String, completion: @escaping(Result<String, Error>) -> Void) {
        // Create use authenticated
        if let email = email {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error{
                    completion(.failure(error))
                }
                
                if let uid = authResult?.user.uid {
                    // Set user data in user firestore table after signup
                    let newUserDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(uid)
                    
                    let timestamp = FieldValue.serverTimestamp()
                    newUserDocument.setData([
                            "xyname" : xyname,
                            "timestamp": timestamp,
                            "level": 0,
                            "xp": 0
                        ]
                    ) { (error) in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        
                        let newProfileData = UpperProfile(
                            nickname: xyname,
                            imageId: "",
                            website: "",
                            followers: 0,
                            following: 0,
                            xp: 0,
                            level: 0,
                            caption: "New profile!")
                        
                        createProfile(profileData: newProfileData) { result in
                            switch result {
                            case .success(let profileId):
                                newUserDocument.setData(
                                    [FirebaseKeys.UserKeys.profile : profileId],
                                    merge: true) { error in
                                    if let error = error {
                                        completion(.failure(error))
                                    }
                                    completion(.success(uid))
                                }
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    }
                } else {
                    fatalError()
                }
            }
        }
    }

    static func createProfile(profileData: UpperProfile, completion: @escaping(Result<String, Error>) -> Void) {
        let uid = Auth.auth().currentUser!.uid
        
        // Create new profile document
        let newProfile = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.profile).addDocument(data: profileData.createNewProfileData) { error in
            if let error = error {
                completion(.failure(error))
            }
        }
        
        print ("Created new profile document with id: \(newProfile.documentID)")
        
        // Add new profile document id to user's profile field
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(uid)
            .setData(
                [FirebaseKeys.UserKeys.profile : newProfile.documentID],
                merge: true) { error in
                if let error = error {
                    completion(.failure(error))
                }
                completion(.success(newProfile.documentID))
            }
    }
}