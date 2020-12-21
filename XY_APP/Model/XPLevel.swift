//
//  XPLevel.swift
//  XY_APP
//
//  Created by Maxime Franchot on 19/12/2020.
//

import UIKit

enum XPLevelType : String, Codable {
    case user
    case post
    case friendship
}


struct XPLevel {
    
    // MARK: - INSTANCE PROPERTIES
    private(set) var xp:Float
    private(set) var level:Int
    
    // MARK: - INHERITANCE PROPERTIES
    
    // Define these properties inside the child classes
    var type: XPLevelType
    
    var levels: [Int] = [] // Array with corresponding levels
    
    var colors: [UIColor] = []
    
    init() {
        xp = 0
        level = 0
        type = .user
        levels = []
        colors = []
    }
}


extension XPLevel: Decodable {
    enum CodingKeys: CodingKey {
      case xp, level, type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        xp = try container.decode(Float.self, forKey: .xp)
        level = try container.decode(Int.self, forKey: .level)
        
        type = try container.decode(XPLevelType.self, forKey: .type)
        
    }
}
