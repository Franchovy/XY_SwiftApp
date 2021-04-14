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
        
        user.nickname = fakeName()
        user.profileImage = UIImage(named: "friend\(Int.random(in: 1...5))")?.pngData()
        user.friendStatus = FriendStatus.none.rawValue
        user.numChallenges = Int16.random(in: 0...100)
        user.numFriends = Int16.random(in: 0...100)
        
        return user
    }
}

func fakeName() -> String {
    let fakeNames = ["Ulrico",
    "Maika",
    "Renato",
    "Oretta",
    "Violante",
    "Gilda",
    "Nestore",
    "Doriana",
    "Noemi",
    "Tancredi",
    "Lino",
    "Anselmo",
    "Evangelista",
    "Matilde",
    "Olimpia",
    "Ruth",
    "Tancredi",
    "Nestore",
    "Olimpia",
    "Grazia",
    "Laura",
    "Nayade",
    "Mercedes",
    "Marco",
    "Siro",
    "Mariapia",
    "Elga",
    "Kociss",
    "Nayade",
    "Cassiopea",
    "Marcella",
    "Marzio",
    "Michele",
    "Nicolas",
    "Christophe",
    "Océane",
    "Hélène",
    "Maggie",
    "Martin",
    "Brigitte",
    "Grégoire",
    "Jacqueline",
    "Lorraine",
    "Marcel",
    "Benoît",
    "Jérôme",
    "Capucine",
    "Inès",
    "Laetitia",
    "Thierry",
    "Gérard",
    "Anastasie",
    "Théodore",
    "Jade",
    "Kieran",
    "Daniel",
    "Gavin",
    "Jack",
    "Stefan",
    "Mia",
    "Reece",
    "Joanne",
    "Joe",
    "Alfie",
    "Gary",
    "Tyler",
    "Ben",
    "Gavin",
    "Kirsty",
    "Bradley",
    "Hollie",
    "Phoebe",
    "Benjamin",
    "Carrie",
    "Jason",
    "Jamie",
    "Abbie",
    "Leo",
    "Mason",
    "Joseph",
    "Mark",
    "Damien",
    "Ava",
    "Harry",
    "Elsie",
    "Leanne",
    "Maisie",
    "Andy",
    "Patricia",
    "Anthony"]
    
    return fakeNames[Int.random(in: 0...fakeNames.count-1)]
}

#endif
