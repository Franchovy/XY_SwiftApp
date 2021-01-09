//
//  UpperProfileModel.swift
//  XY_APP
//
//  Created by Simone on 02/01/2021.
//

import Foundation
import UIKit
import Firebase

struct UpperProfile : Encodable {
    
    var nickname: String
    var imageId: String
    var website: String
    var followers: Int
    var following: Int
    var xp: Int
    var level: Int
    var caption: String
    
}

extension UpperProfile {
    init(data: [String: Any?]) {
        nickname = data[FirebaseKeys.ProfileKeys.nickname] as! String
        caption = data[FirebaseKeys.ProfileKeys.caption] as! String
        imageId = data[FirebaseKeys.ProfileKeys.image] as! String
        website = data[FirebaseKeys.ProfileKeys.website] as! String
        followers = data[FirebaseKeys.ProfileKeys.followers] as! Int
        following = data[FirebaseKeys.ProfileKeys.following] as! Int
        xp = data[FirebaseKeys.ProfileKeys.xp] as! Int
        level = data[FirebaseKeys.ProfileKeys.level] as! Int
    }
}

/// Extension for edit profile
extension UpperProfile {
    var editProfileData: [String: Any] {
        return [FirebaseKeys.ProfileKeys.nickname: nickname,
                FirebaseKeys.ProfileKeys.image: imageId,
                FirebaseKeys.ProfileKeys.website: website,
                FirebaseKeys.ProfileKeys.caption: caption
            ]
    }
    var editProfileDataAsNSDict: NSDictionary {
        return editProfileData as NSDictionary
    }
}

/// Extension for create new profile
extension UpperProfile {
    var createNewProfileData: [String: Any] {
        return [FirebaseKeys.ProfileKeys.nickname: nickname,
                FirebaseKeys.ProfileKeys.image: "defaultProfilePic.png",
                FirebaseKeys.ProfileKeys.website: "xy.com",
                FirebaseKeys.ProfileKeys.followers: 0,
                FirebaseKeys.ProfileKeys.following: 0,
                FirebaseKeys.ProfileKeys.xp: 0,
                FirebaseKeys.ProfileKeys.level: 0,
                FirebaseKeys.ProfileKeys.caption: caption
        ]
    }
    
    var createNewProfileDataAsNSDict: NSDictionary {
        return createNewProfileData as NSDictionary
    }
}
