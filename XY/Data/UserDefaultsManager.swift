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
    
    func removeAll() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
}
