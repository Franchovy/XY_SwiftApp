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
}

#if DEBUG

extension UserDataModel {
    static func fakeUser() -> UserDataModel {
        let context = CoreDataManager.shared.mainContext
        let entity = UserDataModel.entity()
        let user = UserDataModel(entity: entity, insertInto: context)
        
        user.nickname = "test"
        user.profileImage = UIImage(named: "friend1")?.pngData()
        return user
    }
}

#endif
