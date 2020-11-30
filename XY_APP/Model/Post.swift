//
//  Post.swift
//  XY_APP
//
//  Created by Maxime Franchot on 28/11/2020.
//

import Foundation
import UIKit


struct Post {
    var username:String
    var content:String
    
    // Get XP gained from the post since last time this was used.
    func getXP() -> Int {
        return 0
    }
    
    // Function to fetch from API to get all recent posts.
    static func getAllPosts() -> [Post]? {
        // Make API request to backend to signup.
        let getAllPostsRequest = APIRequest(endpoint: "get_all_posts", httpMethod: "GET")
                
        let message = GetAllPostsRequestMessage(token: API.getSessionToken())
        
        getAllPostsRequest.save(message: message, completion: { result in
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
    
        return [Post(username: "Elon Musk", content: "Finally, I have joined XY!"), Post(username: "XY_AI", content: "You are connected to the backend.")]
    }
}

