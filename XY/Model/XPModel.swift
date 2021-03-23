//
//  XPLevel.swift
//  XY_APP
//
//  Created by Maxime Franchot on 10/01/2021.
//

import Foundation


struct XPModel {
    var type: XPLevelType
    var xp: Int
    var level: Int
}

enum XPLevelType {
    case post
    case user
    case viral
    case challenge
}

extension XPModel {
    func getProgress() -> Double {
        return Double(xp) / Double(XPModelManager.shared.getXpForNextLevelOfType(level, type))
    }
    
    mutating func addXP(_ transactionXP: Int) {
        self.xp += transactionXP
        
        if xp < 0 {
            level -= 1
            xp += XPModelManager.shared.getXpForNextLevelOfType(level, type)
        } else {
            let nextLevelXP = XPModelManager.shared.getXpForNextLevelOfType(level, type)
            if xp >= nextLevelXP {
                xp -= nextLevelXP
                level += 1
            }
        }
    }
}

