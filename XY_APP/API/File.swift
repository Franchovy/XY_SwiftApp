//
//  File.swift
//  XY_APP
//
//  Created by Maxime Franchot on 24/11/2020.
//

import Foundation

final class Message: Codable {
    var id:Int?
    var message:String
    
    init(message: String) {
        self.message = message
    }
}

final class LoginRequestMessage: Codable {
    var username:String
    var password:String
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

final class RegisterRequestMessage: Codable {
    
}
