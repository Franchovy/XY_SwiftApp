//
//  UserDataModel.swift
//  XY
//
//  Created by Maxime Franchot on 13/04/2021.
//

import UIKit

struct UserDataModel {
    let nickname: String
    let profileImage: Data
}

extension UserDataModel {
    func toBubble() -> FriendBubbleViewModel {
        FriendBubbleViewModel(image: UIImage(data: profileImage)!, nickname: nickname)
    }
}
