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
        var sessionActive: Bool?
    }
    
    enum SessionResponse {
        case sessionExpired
        case sessionValid
    }
    
    enum SessionResponseError: Error {
        case sessionInvalid
        case connectionProblem
    }
    
    func requestSession(completion: @escaping(Result<SessionResponse, SessionResponseError>) -> Void) {
        var urlRequest = URLRequest(url: URL(string: API_URL + "/open_session")!)
        urlRequest.httpMethod = "GET"
        
        if hasSession() {
            urlRequest.addValue(sessionToken, forHTTPHeaderField: "Session")
        }
        
        let getSessionRequestMessage = GetSessionRequestMessage("Get profile for this guy!")
        
        // Initialise the Http Request
        urlRequest.addValue("application/JSON", forHTTPHeaderField: "Content-Type")
        // Encode the codableMessage properties into JSON for Http Request
        urlRequest.httpBody = try! JSONEncoder().encode(getSessionRequestMessage)
                
        // Open the task as urlRequest
        let dataTask = URLSession.shared.dataTask(with: urlRequest) {data, response, _ in
            // Save response or handle Error
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let jsonData = data else {
                completion(.failure(.sessionInvalid))
                return
            }
            // Handle result
            do {
                // Decode the response
                let messageData = try JSONDecoder().decode(GetSessionResponseMessage.self, from: jsonData)
                
                // Set session data
                if messageData.sessionActive! {
                    completion(.success(.sessionValid))
                } else {
                    completion(.success(.sessionExpired))
                }
            } catch {
                // Error decoding the message
                print("Error decoding the following response: \(httpResponse)")
                print(error)
                completion(.failure(.connectionProblem))
            }
        }
        dataTask.resume() // Execute the httpRequest task
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
