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
    
    static var ownViewModel = ProfileViewModel(
        profileImage: UIImage(named: "friend0"),
        nickname: "my_nickname",
        numChallenges: 23,
        numFriends: 111,
        friendStatus: .none
    )
}
