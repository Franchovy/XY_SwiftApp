//
//  XPLevel.swift
//  XY_APP
//
//  Created by Maxime Franchot on 19/12/2020.
//

import UIKit

enum XPLevelType {
    case user
    case post
    case friendship
}


class XPLevel {
    
    // MARK: - INSTANCE PROPERTIES
    private(set) var xp:Float
    private(set) var level:Int
    
    // MARK: - INHERITANCE PROPERTIES
    
    // Define these properties inside the child classes
    var type: XPLevelType
    
    var levels: [Int] // Array with corresponding levels
    
    var colors: [UIColor]
    
    // MARK: - PUBLIC METHODS
    
    final func addXP(xp: Float) {
        self.xp += xp
    }
    
    init() {
        xp = 0
        level = 0
        type = .user
        levels = []
        colors = []
    }
}


