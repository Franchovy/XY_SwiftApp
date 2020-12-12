//
//  APIRequest.swift
//  XY_APP
//
//  Created by Maxime Franchot on 24/11/2020.
//

import Foundation



struct Session {

    // GLOBAL API VAR - SET THIS TO CONNECT TO BACKEND
    static let url = "https://xy-socialnetwork.com"
    //static let url = "http://172.20.10.4:5000"

    // Username to store as the session
    static var username: String = ""
    
    // Session token coming from server
    static var sessionToken: String = ""
    
    static func hasSession() -> Bool {
        return sessionToken != ""
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
    
    static func requestSession(completion: @escaping(Result<GetSessionResponseMessage, Error>) -> Void) {
        var getSessionRequest = APIRequest(endpoint: "get_profile", httpMethod: "GET")
        var getSessionRequestMessage = GetSessionRequestMessage("Get profile for this guy!")
        var getSessionResponseMessage = GetSessionResponseMessage()
        
        getSessionRequest.save(message: getSessionRequestMessage, response:getSessionResponseMessage, completion: { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    static func savePersistent() {
        
        do {
            print("Saving auth session to coredata persistent storage...")
            // Save Session to CoreDataManager
            try! CoreDataManager.saveSession()
            print("Saved successfully.")
        } catch {
            let nserror = error as NSError
            print("Error solving to session! \(nserror)")
        }
    }
}


enum APIError:Error {
    case responseProblem
    case encodingProblem
    case decodingProblem
    case otherProblem
}

class APIRequest {
    let resourceURL: URL
    let httpMethod: String
    var urlRequest: URLRequest

    
    init(endpoint: String, httpMethod: String) {
        let resourceString = Session.url + "/" + endpoint
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        
        switch httpMethod {
        case "POST": self.httpMethod = httpMethod
        case "GET": self.httpMethod = httpMethod
        case "PUT": self.httpMethod = httpMethod
        default:
            print("ERROR: The given httpMethod is unavailable: \(httpMethod)")
            fatalError()
        }
        
        self.resourceURL = resourceURL
        urlRequest = URLRequest(url: resourceURL)
    }
    
    func setHeader(headerFieldName:String, headerValue:String) {
        urlRequest.setValue(headerValue, forHTTPHeaderField: headerFieldName)
    }
    
    func save<T: Codable, ResponseType: Codable> (message:T,response:ResponseType, completion: @escaping(Result<ResponseType, APIError>) -> Void) {
        
        do {
            // Initialise the Http Request
            urlRequest.httpMethod = self.httpMethod
            urlRequest.addValue("application/JSON", forHTTPHeaderField: "Content-Type")
            // Encode the codableMessage properties into JSON for Http Request
            if urlRequest.httpMethod != "GET" {
                urlRequest.httpBody = try JSONEncoder().encode(message)
                print("Sending request: \(message)") // decode struct
            }
            urlRequest.addValue(Session.sessionToken, forHTTPHeaderField: "Session")
            
            // Open the task as urlRequest
            let dataTask = URLSession.shared.dataTask(with: urlRequest) {data, response, _ in
                // Save response or handle Error
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let jsonData = data else {
                    print("Error: response problem with API call to \(self.resourceURL): \(response)")
                    completion(.failure(.responseProblem))
                    return
                }
                // Handle result
                do {
                    // Decode the response
                    let messageData = try JSONDecoder().decode(ResponseType.self, from: jsonData)
                    completion(.success(messageData))
                } catch {
                    // Error decoding the message
                    print("Error decoding the response.")
                    print(error)
                    completion(.failure(.decodingProblem))
                }
            }
            dataTask.resume() // Execute the httpRequest task
        } catch {
            // Error encoding the message struct
            completion(.failure(.encodingProblem))
        }
    }
}

