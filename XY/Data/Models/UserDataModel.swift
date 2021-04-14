//
//  UserDataModel.swift
//  XY
//
//  Created by Maxime Franchot on 13/04/2021.
//

import UIKit
import CoreData

extension UserDataModel {
    func toBubble() -> FriendBubbleViewModel {
        FriendBubbleViewModel(image: UIImage(data: profileImage!)!, nickname: nickname!)
    }
    
    func toFriendListViewModel() -> FriendListViewModel {
        FriendListViewModel(
            profileImage: UIImage(data: profileImage!)!,
            nickname: nickname!,
            buttonStatus: {
                switch FriendStatus(rawValue: friendStatus!)! {
                case .none:
                    return AddFriendButton.Mode.add
                case .added:
                    return AddFriendButton.Mode.added
                case .addedMe:
                    return AddFriendButton.Mode.addBack
                case .friend:
                    return AddFriendButton.Mode.friend
                }
            }()
        )
    }
}

enum FriendStatus: String {
    case none
    case added
    case addedMe
    case friend
}

#if DEBUG

extension UserDataModel {
    static func fakeUser() -> UserDataModel {
        let context = CoreDataManager.shared.mainContext
        let entity = UserDataModel.entity()
        let user = UserDataModel(entity: entity, insertInto: context)
        
        user.nickname = "test"
        user.profileImage = UIImage(named: "friend1")?.pngData()
        user.friendStatus = FriendStatus.none.rawValue
        user.numChallenges = Int16.random(in: 0...100)
        user.numFriends = Int16.random(in: 0...100)
        
        return user
    }
}

#endif
