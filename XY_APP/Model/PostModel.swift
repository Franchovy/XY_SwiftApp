//
//  Post.swift
//  XY_APP
//
//  Created by Maxime Franchot on 28/11/2020.
//

import Foundation
import UIKit


class PostModel {
    var username:String
    var content:String
    var images:[UIImage]?
    var imageRefs:[String]?
    
    init(username:String, content:String, imageRefs: [String]?) {
        self.username = username
        self.content = content
        self.imageRefs = imageRefs
        self.images = [UIImage]()
    }
    
    //
    func submitPost(completion: @escaping(Result<ResponseMessage, APIError>) -> Void) {
        let submitPostRequest = APIRequest(endpoint: "create_post", httpMethod: "POST")
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
        let getAllPostsRequest = APIRequest(endpoint: "get_all_posts", httpMethod: "GET")
        
        let message = GetAllPostsRequestMessage(token: Session.sessionToken)
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
                        let postModel = PostModel(username: post.username, content: post.content, imageRefs: ["J2NTP9Er4Ad3kRsms7XRoD"])
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
    
    func loadPhotos(completion: @escaping([UIImage]) -> Void) {
        
        if let imageRefs = imageRefs, imageRefs.count > 0 {
            // Load pictures into 'images' from backend using 'imageRefs' array
            for imgRef in imageRefs {
                let img = UIImage(named:imgRef)!
                
                let resizingFactor = 200 / img.size.height
                let newImage = UIImage(cgImage: img.cgImage!, scale: img.scale / resizingFactor, orientation: .up)
                
                images!.append(newImage) // debug: load ref from xcassets
            }
            
            completion(images!)
        }
        
    }
}

