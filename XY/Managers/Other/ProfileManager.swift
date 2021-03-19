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
            if let snapshot = snapshot,
               let userData = snapshot.data(),
               let profileId = userData[FirebaseKeys.UserKeys.profile] as? String
            {
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
    
    func resetProfileImageFile() {
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentPath = documentsUrl.path
        
        let filePath = documentsUrl.appendingPathComponent("profileImage.png")
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
            
            for file in files {
                if "\(documentPath)/\(file)" == filePath.path {
                    try fileManager.removeItem(at: filePath)
                }
            }
        } catch {
            print("Error saving file!")
        }
    }
    
    func saveProfileImageToFile(image:UIImage) {
        
        if ownProfileId != nil {
            let fileManager = FileManager.default
            let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let documentPath = documentsUrl.path
            
            let filePath = documentsUrl.appendingPathComponent("profileImage.png")
            
            do {
                let files = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                
                for file in files {
                    if "\(documentPath)/\(file)" == filePath.path {
                        try fileManager.removeItem(at: filePath)
                    }
                }
            } catch {
                print("Error saving file!")
            }
            
            do {
                let pngData = image.pngData()
                try pngData?.write(to: filePath, options: .atomic)
                
            } catch {
                print("Couldn't write image to file")
            }
        }
    }
    
    func loadProfileImageFromFile() -> UIImage? {
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentPath = documentsUrl.path
        
        let filePath = documentsUrl.appendingPathComponent("profileImage.png")
        
        return UIImage(contentsOfFile: filePath.path)
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
                    
                    ProfileViewModelBuilder.build(with: model, fetchingProfileImage: false, fetchingCoverImage: false) { (viewModel) in
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
            
            print("Fetched profileID")
            
            ProfileFirestoreManager.shared.getProfile(forProfileID: profileId) { profileModel in
                guard let profileModel = profileModel else {
                    return
                }
                
                completion(.success(profileModel))
                
            }
        }
    }
}
