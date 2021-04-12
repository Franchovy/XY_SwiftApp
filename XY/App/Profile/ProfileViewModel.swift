//
//  ProfileViewModel.swift
//  XY
//
//  Created by Maxime Franchot on 31/03/2021.
//

import UIKit

struct ProfileViewModel {
    var profileImage: UIImage?
    var nickname: String
    var numChallenges: Int
    var numFriends: Int
    var friendStatus: AddFriendButton.Mode
}

extension ProfileViewModel {
    static func randomProfileViewModel(basedOn profileData: (String, UIImage)? = nil) -> ProfileViewModel {
        let rand = Int.random(in: 0...4)
        
        return ProfileViewModel(
            profileImage: profileData?.1 ?? UIImage(named: [
                "friend1", "friend2", "friend3", "friend4", "friend5"
            ][rand])!,
            nickname: profileData?.0 ?? ["Girl 1", "Girl 2", "Girl 3", "Lorenzo", "Fil"][rand],
            numChallenges: Int.random(in: 0...1200),
            numFriends: Int.random(in: 0...1000),
            friendStatus: [
                AddFriendButton.Mode.add,
                AddFriendButton.Mode.addBack,
                AddFriendButton.Mode.added,
                AddFriendButton.Mode.friend,
            ][Int.random(in: 0...3)]
        )
    }
}
