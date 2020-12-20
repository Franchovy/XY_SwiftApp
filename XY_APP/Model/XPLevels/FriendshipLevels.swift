//
//  FriendshipLevels.swift
//  XY_APP
//
//  Created by Maxime Franchot on 19/12/2020.
//

import Foundation

class FriendshipLevels : XPLevel {
    
    // MARK: - PROPERTIES
    
    
    override init() {
        super.init()
        type = .friendship
        colors = []
        levels = [100, 1000, 10000, 100000]
    }
}
