//
//  UserViewModel.swift
//  XY
//
//  Created by Maxime Franchot on 15/04/2021.
//

import UIKit

struct UserViewModel: Hashable {
    var profileImage: UIImage?
    let nickname: String
    var friendStatus: FriendStatus
    let numChallenges: Int
    let numFriends: Int
}
