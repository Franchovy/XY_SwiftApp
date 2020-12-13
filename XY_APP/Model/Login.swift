//
//  Login.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/11/2020.
//

import Foundation

struct Login {
    var loginRequestMessage:LoginRequestMessage?
    
    struct LoginRequestMessage: Codable  {
        var username:String = ""
        var password:String = ""
        var rememberMe:Bool = false
        
        init?(username: String, password: String, rememberMe: Bool) {
            self.username = username
            self.password = password
            self.rememberMe = rememberMe
        }
    }
    
    struct LoginResponseMessage: Codable {
        var token: String = ""
        var message: String = ""
        var expiry: Int = 0
        var status: Int = 0
        
        init?(message: String, token: String, status: Int, expiry: Int) {
            self.message = message
            self.token = token
            self.status = status
            self.expiry = expiry
        }
    }
    
    init() {
        loginRequestMessage = nil
    }
    
    mutating func validateLoginForm(username:String, password:String, rememberMe:Bool) {
        
        if username == nil || password == nil || rememberMe == nil {
            fatalError("One or more fields of login were empty!")
        }
        
        // Add validation code here
        loginRequestMessage = LoginRequestMessage(username: username, password: password, rememberMe: rememberMe)
    }
    
    func requestLogin(completion: @escaping(Result<LoginResponseMessage, APIError>) -> Void) {
        // Make API request to backend to login.
        var loginRequest = APIRequest(endpoint: "login", httpMethod: "POST")
        let response = LoginResponseMessage(message: "", token: "", status: 0, expiry: 0)
        // Check LoginRequestMessage is valid
        if (loginRequestMessage != nil) {
            loginRequest.save(message: loginRequestMessage, response: response, completion: { result in
                switch result {
                case .success(let message):
                    if let message = message {
                        //debug
                        print(message)
                        
                        // Save current authentication session
                        Session.username = loginRequestMessage!.username
                        print("Session username: \(Session.username)")
                        Session.sessionToken = message.token
                        Session.setExpiry(expiryTimeInMinutes: message.expiry)
                        
                        Session.savePersistent()
                        
                        DispatchQueue.main.async {
                            completion(.success(message))
                        }
                    }
                case .failure(let error):
                    print("An error occured: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
             }
            })
        }
    }
}
