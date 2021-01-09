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
        return ["nickname": nickname,
                "imageId": imageId,
                "website": website,
                "caption": caption
            ]
    }
    var editProfileDataAsNSDict: NSDictionary {
        return editProfileData as NSDictionary
    }
}

/// Extension for create new profile
extension UpperProfile {
    var createNewProfileData: [String: Any] {
        return ["nickname": nickname,
                "imageId": "defaultProfilePic.png",
                "website": "xy.com",
                "followers": 0,
                "following": 0,
                "xp": 0,
                "level": 0,
                "caption": caption
        ]
    }
    
    var createNewProfileDataAsNSDict: NSDictionary {
        return createNewProfileData as NSDictionary
    }
}
