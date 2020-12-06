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
    var images:[UIImage]?
    
    init(username:String, content:String) {
        self.username = username
        self.content = content
    }
    
    // Get XP gained from the post since last time this was used.
    func getXP() -> Int {
        return 0
    }
    
    //
    func submitPost(completion: @escaping(Result<ResponseMessage, APIError>) -> Void) {
        var submitPostRequest = APIRequest(endpoint: "create_post", httpMethod: "POST")
        let message = CreatePostMessage(content: self.content)
        let response = ResponseMessage()
        submitPostRequest.save(message: message, response: response, completion: { result in
            switch result {
            case .success(let message):
                DispatchQueue.main.async {
                    completion(.success(message))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
        })
    }
    
    // Function to fetch from API to get all recent posts.
    static func getAllPosts(completion: @escaping(Result<[PostModel]?, APIError>) -> Void) -> Void {
        // Make API request to backend to signup.
        var getAllPostsRequest = APIRequest(endpoint: "get_all_posts", httpMethod: "GET")
        
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
    }
}

