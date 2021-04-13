//
//  FriendsDataManager.swift
//  XY
//
//  Created by Maxime Franchot on 13/04/2021.
//

import UIKit

final class FriendsDataManager {
    static var shared = FriendsDataManager()
    private init() { }
    
    
    func getBubbleFromData(dataModel: UserDataModel) -> FriendBubbleViewModel {
        FriendBubbleViewModel(image: UIImage(data: dataModel.profileImage)!, nickname: dataModel.nickname)
    }
}


