//
//  NewProfileViewModel.swift
//  XY
//
//  Created by Maxime Franchot on 18/02/2021.
//

import UIKit

struct NewProfileViewModel {
    var nickname: String
    var relationshipType: RelationshipTypeForSelf
    var numFollowers: Int
    var numFollowing: Int
    var numSwipeRights: Int
    var website: String
    var caption: String
    var profileImage: UIImage?
    var coverImage: UIImage?
    var xp: Int
    var level: Int
    var xyname: String
    var rank: Int?
    var userId: String
    var profileId: String
}
