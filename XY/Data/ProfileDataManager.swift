//
//  ProfileDataManager.swift
//  XY
//
//  Created by Maxime Franchot on 12/04/2021.
//

import UIKit

final class ProfileDataManager {
    static var shared = ProfileDataManager()
    private init() { }
    
    static var profileImage: UIImage? = UIImage(named: "defaultProfileImage")
    static var nickname: String = "my_nickname"
    
    static var ownProfile: UserViewModel {
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
}
