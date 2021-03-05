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
    
    var onInitFinished: (() -> Void)?
    
    var profilesCache = [String: [String: Any]?]()
    
    var listeners = [String: ListenerRegistration]()
    
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
            if let snapshot = snapshot, let userData = snapshot.data() {
                let profileId = userData[FirebaseKeys.UserKeys.profile] as! String
                
                UserDefaults.standard.setValue(["profileId": profileId], forKey: "userData")
                
                self.ownProfileId = profileId
                
                ProfileFirestoreManager.shared.getProfile(forProfileID: profileId) { (profileModel) in
                    if let profileModel = profileModel {
                        self.ownProfile = profileModel
                    }
                    
                    self.onInitFinished?()
                    completion(nil)
                }
            } else {
                try? AuthManager.shared.logout()
            }
        }
    }
    
    func cancelListenerFor(userId: String) {
        if let listener = listeners[userId] {
            listener.remove()
            listeners.removeValue(forKey: userId)
        }
    }
    
    func listenToProfileUpdatesFor(userId: String, callback: @escaping(NewProfileViewModel?) -> Void) {
        ProfileFirestoreManager.shared.getProfileID(forUserID: userId) { (profileId, error) in
            guard let profileId = profileId, error == nil else {
                return
            }
            
            let listener = FirestoreReferenceManager.root.collection("Profiles").document(profileId).addSnapshotListener { (snapshot, error) in
                if let error = error {
                    print(error)
                } else if let snapshot = snapshot, let data = snapshot.data() {
                    let model = ProfileModel(data: data, id: snapshot.documentID)
                    
                    ProfileViewModelBuilder.build(with: model) { (viewModel) in
                        if let viewModel = viewModel {
                            callback(viewModel)
                        }
                    }
                }
            }
            
            self.listeners[userId] = listener
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
        ProfileFirestoreManager.shared.getProfileID(forUserID: userId) { [weak self] (profileId, error) in
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
