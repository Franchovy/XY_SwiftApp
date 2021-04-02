//
//  HomeStateManager.swift
//  XY
//
//  Created by Maxime Franchot on 02/04/2021.
//

import Foundation

final class HomeStateManager {
    
    enum HomeState {
        case normal
        case noFriends
        case noChallengesFirst
        case noChallengesNormal
    }
    
    static var state: HomeState = .normal
    
    
}
