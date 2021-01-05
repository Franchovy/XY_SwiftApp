//
//  UserFirebaseData.swift
//  XY_APP
//
//  Created by Maxime Franchot on 05/01/2021.
//

import Foundation

struct UserData {
    var xyname: String
    var timestamp: Date
    var xp: Int
    var level: Int
}

class UserFirebaseData {
    static var user: UserData?
}
