//
//  Session.swift
//  XY_APP
//
//  Created by Maxime Franchot on 13/12/2020.
//

import Foundation

class Session {
    
    // Authentication Session 
    static var shared = Session()
    
    // Username to store as the session
    var username: String = ""
    // Session token coming from server
    var sessionToken: String = ""
    // Expiry time automatically logs out
    var expiryTime: Date?
    
    func setExpiry(expiryTimeInMinutes: Int) {
        expiryTime = Date(timeIntervalSinceNow:(Double(expiryTimeInMinutes) * 60.0))
    }
    
    func hasSession() -> Bool {
        if let expiryTime = expiryTime {
            if Date() < expiryTime {
                // No expiry
                if sessionToken != "" { return true }
            } else {
                // Session has expired, log out
                print("Session expired, logging out.")
                
                Session.shared.expire()
                CoreDataManager.removeSession()
            }
        }
        return false
    }

    func expire() {
        // Erase data
        username = ""
        sessionToken = ""
        expiryTime = nil
    }
    
    struct GetSessionRequestMessage : Codable {
        var message:String?
        init (_ message: String) {
            self.message = message
        }
    }
    
    struct GetSessionResponseMessage : Codable {
        var message:String?
        var username:String?
        var token:String?
        var expires:String?
    }
    
    func requestSession(completion: @escaping(Result<GetSessionResponseMessage, Error>) -> Void) {
        let getSessionRequest = APIRequest(endpoint: "get_profile", httpMethod: "GET")
        let getSessionRequestMessage = GetSessionRequestMessage("Get profile for this guy!")
        let getSessionResponseMessage = GetSessionResponseMessage()
        
        getSessionRequest.save(message: getSessionRequestMessage, response:getSessionResponseMessage, completion: { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func savePersistent() {
        
        do {
            print("Saving auth session to coredata persistent storage...")
            // Save Session to CoreDataManager
            try CoreDataManager.saveSession()
            print("Saved successfully.")
        } catch {
            let nserror = error as NSError
            print("Error solving to session! \(nserror)")
        }
    }
}
