//
//  APIRequest.swift
//  XY_APP
//
//  Created by Maxime Franchot on 24/11/2020.
//

import Foundation

// GLOBAL API VAR - SET THIS TO CONNECT TO BACKEND
//let API_URL = "https://xy-socialnetwork.com"
let API_URL = "http://192.168.8.111:5000"


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
        let resourceString = API_URL + "/" + endpoint
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
            urlRequest.addValue(Session.shared.sessionToken, forHTTPHeaderField: "Session")
            
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
                    print("Response: \(jsonData)")
                    // Decode the response
                    let messageData = try JSONDecoder().decode(ResponseType.self, from: jsonData)
                    completion(.success(messageData))
                } catch {
                    // Error decoding the message
                    print("Error decoding the following response: \(httpResponse)")
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

