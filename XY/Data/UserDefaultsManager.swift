//
//  UserDefaultsManager.swift
//  XY
//
//  Created by Maxime Franchot on 05/05/2021.
//

import Foundation

final class UserDefaultsManager {
    static var shared = UserDefaultsManager()
    private init() { }
    
    let userInterfaceMode = "userInterfaceMode"
    
    enum UserInterfaceMode: String {
        case light
        case dark
        case systemDefault
    }
    
    func setUserInterfaceMode(_ mode: UserInterfaceMode) {
        UserDefaults.standard.setValue(mode.rawValue, forKey: userInterfaceMode)
    }
    
    func getUserInterfaceMode() -> UserInterfaceMode {
        if let interfaceMode = UserDefaults.standard.string(forKey: userInterfaceMode) {
            return UserInterfaceMode(rawValue: interfaceMode) ?? .systemDefault
        } else {
            return .systemDefault
        }
    }
    
    func removeAll() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
}
