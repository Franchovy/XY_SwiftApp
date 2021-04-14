//
//  UserDataModel.swift
//  XY
//
//  Created by Maxime Franchot on 13/04/2021.
//

import UIKit
//
//struct UserDataModel {
//    let nickname: String
//    let profileImage: Data
//}

extension UserDataModel {
    func toBubble() -> FriendBubbleViewModel {
        FriendBubbleViewModel(image: UIImage(data: profileImage!)!, nickname: nickname!)
    }
}

#if DEBUG

extension UserDataModel {
    static func fakeUser() -> UserDataModel {
        let user = UserDataModel()
        user.nickname = "test"
        user.profileImage = UIImage(named: "friend1")?.pngData()
        return user
    }
}

#endif
