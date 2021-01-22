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
}

extension XPModel {
    static let LEVELS : [ XPLevelType : [Int] ]
        = [ .post : [50, 150, 500, 1500, 5000, 15000],
            .user : [100, 500, 1000, 5000, 10000, 50000]]
    
}
