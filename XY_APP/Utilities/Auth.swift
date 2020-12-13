//
//  Auth.swift
//  XY_APP
//
//  Created by Maxime Franchot on 13/12/2020.
//

import Foundation

class Auth {
    
    struct LogoutRequestMessage : Codable {
        
    }
    
    struct LogoutResponseMessage : Codable {
        var status: Int?
        var message: String?
        
        init(status: Int?, message: String?) {
            self.status = status
            self.message = message
        }
    }
    
    static func logout(completion: @escaping(Result<LogoutResponseMessage, Error>) -> Void) {
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
                DispatchQueue.main.async {
                    completion(.success(message))
                }
            case .failure(let error):
                print("Could not log out, error: \(error)")
                completion(.failure(error))
            }
        })
    }
}
