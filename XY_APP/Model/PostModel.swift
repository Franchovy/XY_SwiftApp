//
//  Post.swift
//  XY_APP
//
//  Created by Maxime Franchot on 28/11/2020.
//

import Foundation
import UIKit


struct PostModel {
    var username:String
    var content:String
    
    // Get XP gained from the post since last time this was used.
    func getXP() -> Int {
        return 0
    }
    
    // Function to fetch from API to get all recent posts.
    static func getAllPosts() -> [PostModel]? {
        // Make API request to backend to signup.
        let getAllPostsRequest = APIRequest(endpoint: "get_all_posts", httpMethod: "GET")
                
        let message = GetAllPostsRequestMessage(token: API.getSessionToken())
        let response = GetPostsResponse()
        getAllPostsRequest.save(message: message,response: response, completion: { result in
            switch result {
            case .success(let message):
                print("POST request response: \"\(message.status)\"")
                
                // This type differs from the previous as ResponseStruct has [Post] type used in response.
                if let posts = message.response {
                    for post in posts {
                        print("New post:")
                        print(post)
                    }
                }
            case .failure(let error):
                print("An error occured: \(error)")
         }
        })
    
        return [PostModel(username: "Elon Musk", content: "Finally, I have joined XY!"), PostModel(username: "XY_AI", content: "You are connected to the backend.")]
    }
}

