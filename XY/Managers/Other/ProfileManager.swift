//
//  ProfileManager.swift
//  XY
//
//  Created by Maxime Franchot on 28/01/2021.
//

import Foundation
import FirebaseFirestore

final class ProfileManager {
    static let shared = ProfileManager()
    private init () { }
    
    var profileId: String?

    func initialiseForCurrentUser(completion: @escaping(Error?) -> Void) {
//        if let userData = UserDefaults.standard.dictionary(forKey: "userData"),
//           let profileId = userData["profileId"] as? String {
//            self.profileId = profileId
//        } else {
            // Fetch profileID from Firestore
            guard let userId = AuthManager.shared.userId else {
                fatalError("Authentication must be done before profile can be accessed.")
            }
            
            FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(userId).getDocument { (snapshot, error) in
                if let error = error {
                    completion(error)
                }
                if let userData = snapshot?.data() {
                    let profileId = userData[FirebaseKeys.UserKeys.profile] as! String
                    
                    UserDefaults.standard.setValue(["profileId": profileId], forKey: "userData")
                    self.profileId = profileId
                    
                    completion(nil)
                }
            }
//        }
    }
    
    func newProfileCreated(withId profileId: String) {
        UserDefaults.standard.setValue(["profileId": profileId], forKey: "userData")
        self.profileId = profileId
    }
    
    func fetchProfile(profileId: String, completion: @escaping(Result<ProfileModel, Error>) -> Void) {
        fatalError("Please implement this")
    }
    
    func fetchProfile(userId: String, completion: @escaping(Result<ProfileModel, Error>) -> Void) {
    
        // Fetch profileId for userId
        FirebaseDownload.getProfileId(userId: userId) { [weak self] (profileId, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            guard let profileId = profileId else {
                return
            }
            
            FirebaseDownload.getProfile(profileId: profileId) { (profileModel, error) in
                if let error = error {
                    completion(.failure(error))
                }
                
                guard let profileModel = profileModel else {
                    return
                }
                
                completion(.success(profileModel))
                
            }
        }
    }
}
