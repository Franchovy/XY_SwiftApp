//
//  ProfileManager.swift
//  XY
//
//  Created by Maxime Franchot on 28/01/2021.
//

import Foundation
import FirebaseFirestore


protocol ProfileManagerDelegate {
    func profileManager(openProfileFor profileId: String)
}

final class ProfileManager {
    static let shared = ProfileManager()
    private init () { }
    
    var profilesCache = [String: [String: Any]?]()
    
    var delegate: ProfileManagerDelegate?
    
    var ownProfile: ProfileModel?
    var ownProfileId: String?
    
    public func openProfileForId(_ profileId: String) {
        delegate?.profileManager(openProfileFor: profileId)
    }

    func initialiseForCurrentUser(completion: @escaping(Error?) -> Void) {

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
                
                self.ownProfileId = profileId
                
                completion(nil)
            } else {
                try? AuthManager.shared.logout()
            }
        }
        
        fetchProfile(userId: userId) { (result) in
            switch result {
            case .success(let profileModel):
                self.ownProfile = profileModel
            case .failure(let error):
                print("Error fetching own profile at initialisation!")
            }
        }

    }
    
    func newProfileCreated(withId profileId: String) {
        UserDefaults.standard.setValue(["profileId": profileId], forKey: "userData")
        self.ownProfileId = profileId
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
