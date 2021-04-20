//
//  ProfileDataManager.swift
//  XY
//
//  Created by Maxime Franchot on 12/04/2021.
//

import UIKit
import CoreData

final class ProfileDataManager {
    static var shared = ProfileDataManager()
    private init() { }
    
    var profileImage: UIImage? {
        get {
            return ( ownProfileModel == nil || ownProfileModel.profileImage == nil) ? nil : UIImage(data: ownProfileModel.profileImage!)!
        }
    }
    
    var nickname: String? {
        get {
            return (ownProfileModel == nil ? nil : ownProfileModel.nickname)
        }
    }
    
    var ownID: String {
        get {
            return AuthManager.shared.userId!
        }
    }
    
    var ownProfileViewModel: UserViewModel {
        get {
            return UserViewModel(
                profileImage: profileImage,
                nickname: nickname!,
                friendStatus: .none,
                numChallenges: Int(ownProfileModel.numChallenges),
                numFriends: Int(ownProfileModel.numFriends)
            )
        }
    }
    
    var ownProfileModel: UserDataModel!
    
    func load(completion: @escaping(() -> Void)) {
        // Fetch profile from firebase
        guard let ownFirebaseId = AuthManager.shared.userId else {
            fatalError("Not authenticated")
        }
        
        let context = CoreDataManager.shared.mainContext
        let entity = UserDataModel.entity()

        let fetchRequest:NSFetchRequest<UserDataModel> = UserDataModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "firebaseID == %@", ownFirebaseId)
        fetchRequest.entity = entity
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if results.count == 1 {
                ownProfileModel = results.first!
                
                completion()
            } else {
                assert(results.count == 0)
                
                FirebaseFirestoreManager.shared.fetchProfile(for: ownFirebaseId) { (result) in
                    defer {
                        completion()
                    }
                    switch result {
                    case .success(let userModel):
                        self.ownProfileModel = userModel
                    case .failure(let error):
                        fatalError("Error fetching own profile from firebase: \(error)")
                    }
                }
                
                FirebaseStorageManager.shared.downloadImage(
                    from: ownFirebaseId) { progress in
                    
                } completion: { (result) in
                    switch result {
                    case .success(let data):
                        self.ownProfileModel.profileImage = data
                    case .failure(let error):
                        print("Error downloading own profile Image: \(error)")
                    }
                }
                
                do {
                    try context.save()
                } catch let error {
                    print("Error creating profile: \(error)")
                }
            }
            
        } catch let error {
            print("Error performing fetch request: \(error)")
        }
    }
    
    func setNickname(as newNickname: String, completion: @escaping(Error?) -> Void) {
        // Set coredata nickname
        ownProfileModel.nickname = newNickname
        CoreDataManager.shared.save()
        
        // Set firebase firestore nickname
        FirebaseFirestoreManager.shared.setProfileData(nickname: nickname!) { error in
            completion(error)
        }
    }
    
    func setImage(as newImage: UIImage, onProgress: @escaping(Double) -> Void, completion: @escaping(Error?) -> Void) {
        // Set coredata image
        
        // Set firebase storage image
        
    }
}
