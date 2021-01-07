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
    
    var xyname: String
    var imageId: String
    var website: String
    var followers: Int
    var following: Int
    var xp: Int
    var level: Int
    var caption: String
    
}

/// Extension for edit profile
extension UpperProfile {
    var editProfileData: [String: Any] {
        return ["imageId": imageId,
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
        return ["imageId": imageId,
                "website": website,
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
