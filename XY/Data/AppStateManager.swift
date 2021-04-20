//
//  AppStateManager.swift
//  XY
//
//  Created by Maxime Franchot on 20/04/2021.
//

import Foundation

final class AppStateManager {
    static var shared = AppStateManager()
    private init() { }
    
    enum HomeState: String {
        case normal
        case noFriends
        case noChallengesFirst
        case noChallengesNormal
        case uninit
    }
    
    var homeState: HomeState = .uninit {
        didSet {
            UserDefaults.standard.setValue(homeState.rawValue, forKey: homeStateKey)
        }
    }
    
    let homeStateKey = "homestate"
    
    func load() -> HomeState {
        return HomeState(rawValue: UserDefaults.standard.value(forKey: homeStateKey) as? String ?? "") ?? .noFriends
    }
}
