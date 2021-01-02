//
//  xy_profiles.swift
//  XY_APP
//
//  Created by Maxime Franchot on 02/01/2021.
//

import Foundation

// COMMON CLASS FOR XYProfiles
class xy_profiles {
    static var shared = xy_profiles()
    
    // MARK: - Properties
    
    var myProfile: xy_profiles_model_myProfile?
}
