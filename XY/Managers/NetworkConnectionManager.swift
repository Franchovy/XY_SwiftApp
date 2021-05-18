//
//  NetworkConnectionManager.swift
//  XY
//
//  Created by Maxime Franchot on 16/05/2021.
//

import Foundation
import Network



final class NetworkConnectionManager {
    static var shared = NetworkConnectionManager()
    private init() {}
    
    var networkMonitor: NWPathMonitor!
    var currentlyConnected = false
    var currentConnectionSpeed: Double = 0.0
    
    func setupNetworkListener() {
        networkMonitor = NWPathMonitor()
        networkMonitor.pathUpdateHandler = { networkPath in
            self.setupNetworkStatus()
        }
        networkMonitor.start(queue: .main)
    }
    
    func setupNetworkStatus(completion: (() -> Void)? = nil) {
        connectedToNetwork() { connectionSpeed, error in
            if error != nil {
                self.currentlyConnected = false
            } else if let connectionSpeed = connectionSpeed {
                self.currentConnectionSpeed = connectionSpeed
            }
        }
    }
    
}
