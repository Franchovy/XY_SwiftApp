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
    
    enum CreateUserError : Error {
        case emailAlreadyInUse
    }
    
    static func createUser(xyname: String, email: String?, phoneNumber: String?, password: String, completion: @escaping(Result<String, Error>) -> Void) {
        // Create use authenticated
        if let email = email {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    completion(.failure(error))
                }
                
                if let uid = authResult?.user.uid {
                    // Set user data in user firestore table after signup
                    let newUserDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(uid)
                    
                    let timestamp = FieldValue.serverTimestamp()
                    newUserDocument.setData([

                            FirebaseKeys.UserKeys.xyname : xyname,
                            FirebaseKeys.UserKeys.timestamp : timestamp,
                            FirebaseKeys.UserKeys.level : 0,
                            FirebaseKeys.UserKeys.xp : 0

                        ]
                    ) { (error) in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        
                        let newProfileData = ProfileModel.createNewProfileData(nickname: xyname)
                        
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
                    completion(.failure(CreateUserError.emailAlreadyInUse))
                }
            }
        }
    }

    static func createProfile(profileData: [String: Any], completion: @escaping(Result<String, Error>) -> Void) {
        let uid = Auth.auth().currentUser!.uid
        
        // Create new profile document
        let newProfile = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.profile).addDocument(data: profileData) { error in
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
