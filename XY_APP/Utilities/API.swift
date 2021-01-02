//
//  API.swift
//  XY_APP
//
//  Created by Maxime Franchot on 16/12/2020.
//

import Foundation


class API {
    
    static var shared = API()
    
    enum ConnectionStatus : Error {
        case hasConnection
        case noConnection
    }
    
    var hasConnection = true
    
    func checkConnection(closure: @escaping(ConnectionStatus) -> Void) {
        var urlRequest = URLRequest(url: URL(string: API_URL + "/index")!)
        // Initialise the Http Request
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/JSON", forHTTPHeaderField: "Content-Type")
        
        // Open the task as urlRequest
        let dataTask = URLSession.shared.dataTask(with: urlRequest) {data, response, _ in
            // Save response or handle Error
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let jsonData = data else {
                closure(.noConnection)
                return
            }
            // Handle result
            do {
                // Decode the response
                //let messageData = try JSONDecoder().decode(ResponseType.self, from: jsonData)
                closure(.hasConnection)
            } catch {
                // Error decoding the message
                fatalError()
            }
        }
        dataTask.resume()
    }
}
