//
//  UserDataModel.swift
//  XY
//
//  Created by Maxime Franchot on 13/04/2021.
//

import UIKit
import CoreData

extension UserDataModel {
    
    func toViewModel() -> UserViewModel {
        UserViewModel(
            coreDataID: id,
            profileImage: profileImage != nil ? UIImage(data: profileImage!)! : nil,
            nickname: nickname!,
            friendStatus: FriendStatus(rawValue: friendStatus ?? "none") ?? .none,
            numChallenges: Int(numChallenges),
            numFriends: Int(numFriends)
        )
    }
}

enum FriendStatus: String {
    case none
    case added
    case addedMe
    case friend
}
