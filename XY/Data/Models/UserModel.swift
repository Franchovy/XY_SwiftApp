//
//  UserModel.swift
//  XY
//
//  Created by Maxime Franchot on 02/05/2021.
//

import UIKit

struct UserModel {
    var nickname:String
    var numFriends: Int
    var numChallenges: Int
    var firebaseID: String
    var profileImageFirebaseID: String?
    var friendStatus: FriendStatus
}
