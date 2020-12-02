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
    
    init(username:String, content:String) {
        self.username = username
        self.content = content
    }
    
    // Get XP gained from the post since last time this was used.
    func getXP() -> Int {
        return 0
    }
    
    //
    func submitPost() {
        let submitPostRequest = APIRequest(endpoint: "create_post", httpMethod: "POST")
        let message = CreatePostMessage(content: self.content)
        let response = ResponseMessage()
        submitPostRequest.save(message: message, response: response, completion: { result in
            switch result {
            case .success(let message):
                print("POST request response: \(message.message)")
            case .failure(let error):
                print("Error with request response: \(error)")
            }
            
        })
    }
    
    // Function to fetch from API to get all recent posts.
    static func getAllPosts(completion: @escaping(Result<[PostModel]?, APIError>) -> Void) -> [PostModel]? {
        // Make API request to backend to signup.
        let getAllPostsRequest = APIRequest(endpoint: "get_all_posts", httpMethod: "GET")
                
        let message = GetAllPostsRequestMessage(token: API.getSessionToken())
        let response = GetPostsResponse()
        getAllPostsRequest.save(message: message,response: response, completion: { result in
            switch result {
            case .success(let message):
                print("POST request response: \"\(message.status)\"")
                var postmodels = [PostModel]()
                
                // Decode posts json into postModels for app use
                if let posts = message.response {
                    for post in posts {
                        print("New post:")
                        print(post)
                        let postModel = PostModel(username: post.username, content: post.content)
                        postmodels.append(postModel)
                        
                    }
                }
                DispatchQueue.main.async {
                    completion(.success(postmodels))
                }
                
            case .failure(let error):
                print("An error occured: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
         }
        })
    
        return [PostModel(username: "Elon Musk", content: "Finally, I have joined XY!"), PostModel(username: "XY_AI", content: "You are connected to the backend.")]
    }
}

