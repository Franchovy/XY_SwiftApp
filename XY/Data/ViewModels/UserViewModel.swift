//
//  UserViewModel.swift
//  XY
//
//  Created by Maxime Franchot on 15/04/2021.
//

import UIKit

struct UserViewModel: Hashable {
    var coreDataID: ObjectIdentifier
    var profileImage: UIImage?
    var nickname: String
    var friendStatus: FriendStatus
    var numChallenges: Int
    var numFriends: Int
}
