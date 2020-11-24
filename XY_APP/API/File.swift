//
//  File.swift
//  XY_APP
//
//  Created by Maxime Franchot on 24/11/2020.
//
// Message classes for passing data to the Backend. These are all our defined types for different uses.

import Foundation

enum CodableMessageError: Error {
    case invalidMethodError
}

final class Message: Codable {
    var id:Int?
    var message:String
    var token:String?
    
    init(message: String) {
        self.message = message
    }
}

final class LoginRequestMessage: Codable {
    var username:String
    var password:String
    
    init?(username: String, password: String) throws {
        self.username = username
        self.password = password
        
    }
}

final class RegisterRequestMessage: Codable {
    var username:String
    var password:String
    
}

final class ProfileEditMessage: Codable {
    
}

final class CreatePostMessage: Codable {
    
}
