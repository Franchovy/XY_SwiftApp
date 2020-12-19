//
//  Auth.swift
//  XY_APP
//
//  Created by Maxime Franchot on 13/12/2020.
//

import Foundation

class Auth {
    
    // MARK: - PROPERTIES
    static var shared = Auth()
    
    
    // MARK: - STRUCTS
    
    struct LoginRequestMessage: Codable  {
        var username:String
        var password:String
        var rememberMe:Bool
    }
    
    struct LoginResponseMessage: Codable {
        var token: String?
        var message: String?
        var expiry: Int?
        var status: Int?
    }
    
    struct LogoutRequestMessage : Codable {
        
    }
    
    struct LogoutResponseMessage : Codable {
        var status: Int?
        var message: String?
    }
    
    struct SignupRequestMessage: Codable  {
        var username:String = ""
        var email:String = ""
        var phoneNumber:String = ""
        var password:String = ""
    }
    
    struct SignupResponseMessage: Codable {
        var message:String?
        var username:String?
        var token:String?
        var id:String?
    }
    
    // MARK: - ENUMS
    
    enum LoginError : Error {
        case invalidUserPassword
        case connectionProblem
    }
    
    enum SignupError : Error {
        case usernameAlreadyInUse
        case emailAlreadyInUse
        case phoneAlreadyInUse
        case passwordNotAccepted
        case connectionProblem
    }
    
    enum LogoutError: Error {
        case alreadyLoggedOut
        case connectionProblem
    }
    
    // MARK: - PUBLIC METHODS
    
    func requestLogin(username: String, password: String, rememberMe: Bool, completion: @escaping(Result<Void, LoginError>) -> Void) {
        // Make API request to backend to login.
        var loginRequestMessage = LoginRequestMessage(username: username, password: password, rememberMe: rememberMe)
        var loginRequest = APIRequest(endpoint: "login", httpMethod: "POST")
        let response = LoginResponseMessage()
        // Check LoginRequestMessage is valid
        if (loginRequestMessage != nil) {
            loginRequest.save(message: loginRequestMessage, response: response, completion: { result in
                switch result {
                case .success(let message):
                    
                    if let token = message.token, let expiry = message.expiry {
                        // Save current authentication session
                        Session.shared.username = username
                        Session.shared.sessionToken = message.token!
                        Session.shared.setExpiry(expiryTimeInMinutes: message.expiry!)
                        // Save persistent
                        Session.shared.savePersistent() // TODO error handling
                        completion(.success(()))
                    }
                case .failure(let error):
                    print("An error occured: \(error)")
                    completion(.failure(.invalidUserPassword))
             }
            })
        }
    }
    
    func logout(completion: @escaping(LogoutError?) -> Void) {
        // Log out of backend
        let logoutRequest = APIRequest(endpoint: "logout", httpMethod: "POST")
        let logoutRequestMessage = LogoutRequestMessage()
        let logoutResponseMessage = LogoutResponseMessage(status: nil, message: nil)
        
        logoutRequest.save(message: logoutRequestMessage, response: logoutResponseMessage, completion: { result in
            switch result {
            case .success(let message):
                // Remove local store
                CoreDataManager.removeSession() 
                // Call completion
                
                completion(nil)
                
            case .failure(let error):
                print("Probably a decoding problem. I'll log you out anyways.")
                completion(nil)
            }
        })
    }
    
    
    func register(username: String, password: String, email: String, phoneNumber: String, completion: @escaping(Result<Void, SignupError>) -> Void) { //todo remove return value
        let requestMessage = SignupRequestMessage(username: username, email: email, phoneNumber: phoneNumber, password: password)
        
        // Make API request to backend to signup.
        let request = APIRequest(endpoint: "register", httpMethod: "POST")
        let responseMessage = SignupResponseMessage()
        // Check LoginRequestMessage is valid
        
        request.save(message: requestMessage, response: responseMessage, completion: { result in
            switch result {
            case .success(let message):
                
                completion(.success(()))
            case .failure(let error):
                print("Signup error occured: \(error)")
                completion(.failure(.usernameAlreadyInUse))
         }
        })
    }
    
    static func forceLogout() {
        CoreDataManager.removeSession() 
    }
}
