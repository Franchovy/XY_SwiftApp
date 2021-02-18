//
//  UserModel.swift
//  XY
//
//  Created by Maxime Franchot on 18/02/2021.
//

import Foundation

struct UserModel {
    let id: String
    let xyname: String
    let timestamp: Date
    let xp: Int
    let level: Int
    let profileId : String
    let hidden: Bool?
    let fcmToken : String?
}
