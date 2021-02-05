//
//  XPModelManager.swift
//  XY
//
//  Created by Maxime Franchot on 05/02/2021.
//

import Foundation

final class XPModelManager {
    static let shared = XPModelManager()
    private init() { }
    
    private let levels : [ XPLevelType : [Int] ]
        = [ .post : [50, 150, 500, 1500, 5000, 15000],
            .user : [100, 500, 1000, 5000, 10000, 50000],
            .viral : [25, 50, 100, 250, 500, 1000]]
    
    private let viralLives = [5, 10, 15, 20, 25, 30]
    
    
    /// Loads updates models from firestore
    func loadXPModels() {
        
    }
    
    /// Returns the XP Requirement to complete *level* of provided *type*
    func getXpForNextLevelOfType(_ level: Int, _ type: XPLevelType) -> Int {
        if let nextLevelXPRequirement = levels[type]?[level] {
            return nextLevelXPRequirement
        } else {
            return -1
        }
    }
    
    func getLivesLeftForLevel(_ level: Int) -> Int {
        if level < viralLives.count {
            return viralLives[level]
        } else {
            return -1
        }
    }
    
}
