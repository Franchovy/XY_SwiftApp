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

class Algorithm {
    static var shared = Algorithm()
    
    func addXPfromPostFeedback(post: PostData) -> XPLevel {
        // Uses a copy of the backend algorithm to calculate how much XP to give to a post based on feedback.
        guard let feedback = post.feedback  else { return XPLevel(type: .post) }
        let viewTime = feedback.viewTime
        let swipeRights = feedback.swipeRight
        var xpLevel = post.xpLevel
        
        xpLevel.addXP(xp: viewTime + Float(swipeRights * 15))
        return xpLevel
    }
}

// Class defining different level types and progressions.
class Levels {
    static var shared = Levels()
    
    // Returns the total amount of XP needed for the next level.
    func getNextLevel(xpLevel: XPLevel) -> Float {
        return getLevels(type: xpLevel.type)[xpLevel.level]
    }
    
    func getLevels(type: XPLevelType) -> [Float] {
        switch type {
        case .post:
            return [100, 500, 1500, 5000]
        default:
            fatalError("Please define the levels in this class.")
        }
    }
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
    
    init(type: XPLevelType) {
        xp = 0
        level = 0
        self.type = type
        levels = []
        colors = []
    }
    
    mutating func addXP(xp: Float) {
        self.xp += xp
    }
    
    mutating func levelUp() {
        level += 1
        xp = 0
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
