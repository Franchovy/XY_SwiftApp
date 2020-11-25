//
//  APIRequest.swift
//  XY_APP
//
//  Created by Maxime Franchot on 24/11/2020.
//

import Foundation


struct API {

    // GLOBAL API VAR - SET THIS TO CONNECT TO BACKEND
    static let url = "http://192.168.1.2:5000"

    // Session token coming from server
    static var sessionToken: String = ""

    // Static function for setting the session token
    static func setSessionToken(newSessionToken: String) {
        API.sessionToken = newSessionToken
    }
    
    // Static function for getting the session token
    static func getSessionToken() -> String {
        return API.sessionToken
    }
}


enum APIError:Error {
    case responseProblem
    case encodingProblem
    case decodingProblem
    case otherProblem
}

struct APIRequest {
    let resourceURL: URL
    let httpMethod: String
    
    
    init(endpoint: String, httpMethod: String) {
        let resourceString = API.url + "/" + endpoint
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
    }
    
    func save<T: Encodable> (_ messageToSave:T, requestResponse:Message, completion: @escaping(Result<Message, APIError>) -> Void) {
        do {
            // Initialise the Http Request
            var urlRequest = URLRequest(url: resourceURL)
            urlRequest.httpMethod = self.httpMethod
            urlRequest.addValue("application/JSON", forHTTPHeaderField: "Content-Type")
            // Encode the codableMessage properties into JSON for Http Request
            urlRequest.httpBody = try JSONEncoder().encode(messageToSave)
            
            // Open the task as urlRequest
            let dataTask = URLSession.shared.dataTask(with: urlRequest) {data, response, _ in
                // Save response or handle Error
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let jsonData = data else {
                    completion(.failure(.responseProblem))
                    return
                }
                // Handle result
                do {
                    // Decode the response
                    let messageData = try JSONDecoder().decode(Message.self, from: jsonData) // Todo: Change Message struct for response
                    completion(.success(messageData))
                } catch {
                    // Error decoding the message
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

