//
//  ProfileDataManager.swift
//  XY
//
//  Created by Maxime Franchot on 12/04/2021.
//

import UIKit

final class ProfileDataManager {
    static var shared = ProfileDataManager()
    private init() { }
    
    var nickname: String? = "my_nickname"
    var profileImage: UIImage? = UIImage(named: "friend0")
}
