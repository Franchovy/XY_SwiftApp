//
//  AuthManager.swift
//  XY
//
//  Created by Maxime Franchot on 02/02/2021.
//

import Foundation
import Firebase
import FirebaseAuth

final class AuthManager {
    static let shared = AuthManager()
    private init() { }
    
    var userId: String?
    var email: String?
    
    func isLoggedIn() -> Bool {
        if let currentUser = Auth.auth().currentUser {
            userId = currentUser.uid
            email = currentUser.email
            
            return true
        } else {
            return false
        }
    }
    
    func verifyPassword(password: String, completion: @escaping(Bool?, Error?) -> Void) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        user.reauthenticate(with: credential) { (result, error) in
            if let error = error {
                if error.localizedDescription.contains("The password is invalid or the user does not have a password.") {
                    completion(false, nil)
                } else {
                    completion(nil, error)
                }
            } else if let result = result {
                completion(true, nil)
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("Error logging out: \(error)")
        }
    }
    
    func changePassword(newPassword: String, completion: @escaping(Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        user.updatePassword(to: newPassword) { (error) in
            completion(error)
        }
    }
    
    
    
    func login(withEmail email: String, password: String, completion: @escaping(Result<Bool, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let uid = authResult?.user.uid else { fatalError() }
                self.userId = uid
                
                // Load profile data
                ProfileManager.shared.initialiseForCurrentUser(completion: {_ in })
                
                completion(.success(true))
            }
        }
    }
    
    enum CreateUserError : Error {
        case emailAlreadyInUse
    }
    
    func signUp(xyname: String, email: String?, phoneNumber: String?, password: String, completion: @escaping(Result<String, Error>) -> Void) {
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
                        
                        self.createProfile(profileData: newProfileData) { result in
                            switch result {
                            case .success(let profileId):
                                newUserDocument.setData([FirebaseKeys.UserKeys.profile : profileId], merge: true) { error in
                                    if let error = error {
                                        completion(.failure(error))
                                    }
                                    
                                    ProfileManager.shared.newProfileCreated(withId: profileId)
                                    
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

    func createProfile(profileData: [String: Any], completion: @escaping(Result<String, Error>) -> Void) {
        guard let userId = userId else { return }
        
        // Create new profile document
        let newProfile = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.profile).addDocument(data: profileData) { error in
            if let error = error {
                completion(.failure(error))
            }
        }
        
        print ("Created new profile document with id: \(newProfile.documentID)")
        
        // Add new profile document id to user's profile field
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(userId)
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
