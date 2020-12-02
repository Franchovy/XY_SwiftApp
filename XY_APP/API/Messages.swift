//
//  File.swift
//  XY_APP
//
//  Created by Maxime Franchot on 24/11/2020.
//
// Message classes for passing data to the Backend. These are all our defined types for different uses.

import Foundation

// Error types for http data messages
enum CodableMessageError: Error {
    case invalidMethodError
}

// Default message class for sending and receiving http data
final class Message: Codable {
    var id:Int?
    var message:String
    var data:String?
    var token:String?
    
    init(message: String) {
        self.message = message
    }
}

final class ResponseMessage: Codable {
    var response: String?
    var mimetype: String?
    var status: Int
    var message:String?
    var data:String?
    var token:String?
    
    init() {
        response = nil
        mimetype = nil
        status = 0
        message = nil
        data = nil
        token = nil
    }
}

final class GetPostsResponse: Codable {
    var response: [Post]?
    var mimetype: String?
    var status: Int
    var message:String?
    var data:String?
    var token:String?
    
    init() {
        response = nil
        mimetype = nil
        status = 0
        message = nil
        data = nil
        token = nil
    }
}

struct Post: Codable {
    var username: String
    var content: String
    
    enum CodingKeys: String, CodingKey {
       case username, content
    }
}


// RegisterRequestMessage for sending register new user through POST request.
final class RegisterRequestMessage: Codable {
    var username:String
    var password:String
    
    init?(username: String, password: String) {
        self.username = username
        self.password = password
    }
}


final class GetAllPostsRequestMessage: Codable {
    var token:String
    init?(token: String) {
        self.token = token
    }
}

final class GetRequestEmptyMessage: Codable {
}

final class CreatePostMessage: Codable {
    
}

final class ProfileEditMessage: Codable {
    
}
