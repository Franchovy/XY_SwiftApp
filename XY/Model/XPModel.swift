//
//  XPLevel.swift
//  XY_APP
//
//  Created by Maxime Franchot on 10/01/2021.
//

import Foundation


struct XPModel {
    var type: XPLevelType
    var xp: Int {
        didSet {
            
        }
    }
    var level: Int
}

enum XPLevelType {
    case post
    case user
    case viral
}
