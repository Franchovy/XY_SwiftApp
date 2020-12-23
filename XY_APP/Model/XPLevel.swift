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
            return [100, 1000, 10000, 100000, 1000000]
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
        
        switch type {
        case .post:
            levels = [100, 1000, 10000, 100000]
            colors = [.lightGray, .green, .yellow, .orange]
        default:
            levels = []
            colors = []
        }
    }
    
    mutating func addXP(xp: Float) {
        print("Adding XP: \(xp)")
        self.xp += xp
        
        // Level up
        if Int(self.xp) > levels[level] {
            print("Level up!")
            self.xp -= Float(levels[level])
            level += 1
        }
    }
    
    func getColor() -> UIColor {
        return colors[level]
    }
}


extension XPLevel: Decodable {
    enum CodingKeys: CodingKey {
      case xp, level, type
    }
    
    init(type: XPLevelType, xp: Int, level: Int) {
        self.init(type: type)
        
        self.xp = Float(xp)
        self.level = level
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        xp = try container.decode(Float.self, forKey: .xp)
        level = try container.decode(Int.self, forKey: .level)
        
        type = try container.decode(XPLevelType.self, forKey: .type)
        
    }
}
