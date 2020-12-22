//
//  FeedbackAPI.swift
//  XY_APP
//
//  Created by Maxime Franchot on 21/12/2020.
//

import Foundation

class FeedbackAPI {
    
    static var shared = FeedbackAPI()
    
    struct FeedbackData: Encodable {
        var data: [String: Feedback]
    }
    
    struct PostXPUpdateData : Decodable {
        var id: String
        var xp: Int
    }
    
    struct SubmitFeedbackResponse : Decodable {
        var posts: [PostXPUpdateData]
        var xp: Int
    }
    
    
    func submitFeedback(postId: String, feedback: Feedback, completion: @escaping(Result<[PostXPUpdateData],APIError>) -> Void) {
        var feedbackData = FeedbackData(data: [:])
        feedbackData.data[postId] = feedback
        
        var urlRequest = URLRequest(url: URL(string: API_URL + "/submit_feedback")!)
        urlRequest.httpMethod = "POST"
        
        urlRequest.addValue(Session.shared.sessionToken, forHTTPHeaderField: "Session")
        urlRequest.addValue("application/JSON", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(feedbackData)
        urlRequest.httpBody = jsonData
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            // submit message to backend
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let jsonData = data else {
                completion(.failure(.responseProblem))
                return
            }
            // Handle result
            do {
                // Decode the response
                let messageData = try JSONDecoder().decode(SubmitFeedbackResponse.self, from: jsonData)
                print("Received response for feedback: \(messageData)")
                
                // TODO : - Add xp to user.
                // User.shared.xplevel.xp += messageData.xp
                completion(.success(messageData.posts))
            } catch {
                // Error decoding the message
                print("Error decoding the following response: \(httpResponse)")
                print(error)
                completion(.failure(.decodingProblem))
            }
        }
        dataTask.resume() // Execute the httpRequest task
    }
}
