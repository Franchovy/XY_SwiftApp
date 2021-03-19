//
//  ProfileFirestoreManager.swift
//  XY
//
//  Created by Maxime Franchot on 04/03/2021.
//

import UIKit

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
    
    func setProfileImage(image: UIImage) {
        guard let profileID = ProfileManager.shared.ownProfileId else {
            return
        }
        
        StorageManager.shared.uploadPhoto(image, storageId: profileID) { (result) in
            switch result {
            case .success(let imageID):
                
                FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.profile)
                    .document(profileID)
                    .setData([ FirebaseKeys.ProfileKeys.profileImage : "\(profileID)/\(imageID)" ], merge: true)
                
                    ProfileManager.shared.ownProfile?.profileImageId = "\(profileID)/\(imageID)"
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func setProfileCaption(_ caption: String) {
        guard let profileID = ProfileManager.shared.ownProfileId else {
            return
        }
        
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.profile)
            .document(profileID)
            .setData([ FirebaseKeys.ProfileKeys.caption : caption ], merge: true)
    }
    
    func setProfileNickname(_ nickname: String) {
        guard let profileID = ProfileManager.shared.ownProfileId else {
            return
        }
        
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.profile)
            .document(profileID)
            .setData([ FirebaseKeys.ProfileKeys.nickname : nickname ], merge: true)
    }
}
