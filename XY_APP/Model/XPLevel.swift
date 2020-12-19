//
//  XPLevel.swift
//  XY_APP
//
//  Created by Maxime Franchot on 19/12/2020.
//

import Foundation

class XPLevel {
    static var userXPLevel = XPLevel()
    
    var xp:Float
    var level:Int
    
    init?(coder: NSCoder) {
        if coder.containsValue(forKey: "xp") && coder.containsValue(forKey: "level") { return nil }
        
        xp = coder.decodeFloat(forKey: "xp")
        level = coder.decodeInteger(forKey: "level")
    }
    
    init() {
        xp = 0
        level = 0
    }
    
    func addXP(xp: Float) {
        self.xp += xp
    }
    
    func saveData() {
        
        //XPLevel.userXPLevel
        
        //UserDefaults.register(["xp":XPLevel.userXPLevel, "level":XPLevel.userXPLevel.level])
    }
}
