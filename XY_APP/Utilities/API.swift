//
//  API.swift
//  XY_APP
//
//  Created by Maxime Franchot on 16/12/2020.
//

import Foundation


class API {
    
    enum ConnectionStatus : Error {
        case hasConnection
        case noConnection
    }
    
    let hasConnection = true
    
    func checkConnection(closure: @escaping(ConnectionStatus) -> Void) {
        hasConnection ? closure(.hasConnection) : closure(.noConnection)
    }
}
