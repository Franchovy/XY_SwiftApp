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
    
    var profileImage: UIImage? = UIImage(named: "defaultProfileImage")
    var nickname: String = "my_nickname"
    
    var ownID: String {
        get {
            return ownProfileModel.firebaseID!
        }
    }
    
    var ownProfileViewModel: UserViewModel {
        get {
            return UserViewModel(
                profileImage: UIImage(data: ownProfileModel.profileImage!)!,
                nickname: ownProfileModel.nickname!,
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
                        print("Error fetching own profile from firebase: \(error)")
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
}
