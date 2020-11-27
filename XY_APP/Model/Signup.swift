//
//  Signup.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/11/2020.
//

import Foundation

struct Signup {
    var signupRequestMessage:SignupRequestMessage?
    
    struct SignupRequestMessage: Codable  {
        var username:String = ""
        var email:String = ""
        var phoneNumber:String = ""
        var password:String = ""
        
        init?(username: String, password: String, email: String, phoneNumber:String) {
            self.username = username
            self.password = password
            self.email = email
            self.phoneNumber = phoneNumber
        }
    }
    
    init() {
        signupRequestMessage = nil
    }
    
    mutating func validateSignupForm(username:String, password:String, email:String, phoneNumber:String) {
        
        if username == nil || password == nil || email == nil || phoneNumber == nil {
            fatalError("One or more fields of signup were empty!")
        }
        
        // Add validation code here
        signupRequestMessage = SignupRequestMessage(username: username, password: password,  email: email, phoneNumber: phoneNumber)
    }
    
    func requestSignup() -> Bool {
        // Make API request to backend to signup.
        let signupRequest = APIRequest(endpoint: "register", httpMethod: "POST")
        
        // Check LoginRequestMessage is valid
        if (signupRequestMessage != nil) {
            signupRequest.save(message: signupRequestMessage, completion: { result in
                switch result {
                case .success(let message):
                    print("POST request response: \"" + message.message + "\"")
                    let sessionToken = message.token ?? ""
                    print(sessionToken)
                    API.setSessionToken(newSessionToken: sessionToken)
                case .failure(let error):
                    print("An error occured: \(error)")
             }
            })
        }
        return false
    }
}
