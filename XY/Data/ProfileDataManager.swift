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
    
    var ownProfile: UserViewModel {
        get {
            UserViewModel(
                profileImage: profileImage ?? UIImage(named: "defaultProfileImage")!,
                nickname: nickname,
                friendStatus: .none,
                numChallenges: 12,
                numFriends: 69
            )
        }
    }
    
    var ownID: String {
        get {
            return ownProfileModel.firebaseID!
        }
    }
    
    var ownProfileModel: UserDataModel!
    
    func load() {
        
        let context = CoreDataManager.shared.mainContext
        let entity = UserDataModel.entity()

        let fetchRequest:NSFetchRequest<UserDataModel> = UserDataModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "nickname == %@", nickname)
        fetchRequest.entity = entity
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if results.count == 1 {
                ownProfileModel = results.first!
            } else {
                assert(results.count == 0)
                
                ownProfileModel = UserDataModel(entity: entity, insertInto: context)
                
                ownProfileModel.nickname = ownProfile.nickname
                ownProfileModel.numChallenges = Int16(ownProfile.numChallenges)
                ownProfileModel.numFriends = Int16(ownProfile.numFriends)
                ownProfileModel.profileImage = UIImage(named: "defaultProfileImage")!.pngData()!
                ownProfileModel.friendStatus = FriendStatus.none.rawValue
                
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
