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
            self.rememberMe = false
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
    
    func requestLogin(completion: @escaping(Result<ResponseMessage, APIError>) -> Void) {
        // Make API request to backend to login.
        let loginRequest = APIRequest(endpoint: "login", httpMethod: "POST")
        let response = ResponseMessage()
        // Check LoginRequestMessage is valid
        if (loginRequestMessage != nil) {
            loginRequest.save(message: loginRequestMessage, response: response, completion: { result in
                switch result {
                case .success(let message):
                    if let message = message.message {
                        print("POST request response: \"" + message + "\"")
                    }
                    let sessionToken = message.token ?? ""
                    print(sessionToken)
                    API.setSessionToken(newSessionToken: sessionToken)
                    DispatchQueue.main.async {
                        completion(.success(message))
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
