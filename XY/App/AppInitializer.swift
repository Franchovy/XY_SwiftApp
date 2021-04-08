//
//  AppInitializer.swift
//  XY
//
//  Created by Maxime Franchot on 08/04/2021.
//

import Foundation

final class AppInitializer {
    static let shared = AppInitializer()
    
    private init() { }
    
    var randomSession: Int!
    func setRandomSession() {
        randomSession = Int.random(in: 0...10)
        
        if randomSession > 7 {
            setNumChallengesNotification(numChallenges: randomSession - 7)
        }
    }
    
    var challengesToSee: Int = 3
    private func setNumChallengesNotification(numChallenges: Int) {
        challengesToSee = numChallenges
    }
}
