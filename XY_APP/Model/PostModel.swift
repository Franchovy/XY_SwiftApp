//
//  Post.swift
//  XY_APP
//
//  Created by Maxime Franchot on 28/11/2020.
//

import Foundation
import UIKit


class Post {
    var id:String
    var username:String
    var timestamp: Date
    var content:String
    var images:[UIImage]?
    var imageRefs:[String]?
    
    required init(id:String, username:String, timestamp: Date, content:String, imageRefs:[String]?) {
        self.id = id
        self.username = username
        self.timestamp = timestamp
        self.content = content
        self.imageRefs = imageRefs
    }
    
    // MARK - ENUMS
    
    enum CreatePostError:Error {
        case otherProblem
        case connectionProblem
    }
    
    // MARK - DATA MODELS
    
    struct PostData: Codable {
        var id: String
        var username: String
        var timestamp: String
        var content: String
        var images: String?
    }
    
    // MARK - PUBLIC METHODS
    
    func loadPhotos(completion: @escaping([UIImage]) -> Void) {
        
    }
    
    func submitPost(images: [UIImage]?, completion: @escaping(Result<PostData, CreatePostError>) -> Void) {
        
        // Upload any images submitted
        if let images = images, images.count > 0 {
            for image in images {
                ImageCache.insertAndUpload(image: image, closure: { result in
                    switch result {
                    case .success(let imageId):
                        
                        self.imageRefs?.append(imageId)
                        
                        // If all uploads are complete send Submit Post request
                        if self.imageRefs?.count == images.count {
                            self.submitCreatePostRequest(content: self.content, imageIds: self.imageRefs?.first, closure: completion)
                        }
                        
                    case .failure(let error):
                        print("Error submitting image for post: \(error)")
                    }
                })
            }
        } else {
            // No images to upload, submit directly
            self.submitCreatePostRequest(content: self.content, imageIds: nil, closure: completion)
        }
    }
    
    // MARK - API STRUCTS
    
    fileprivate struct CreatePostMessage: Codable {
        var content: String?
        var images: String?
    }
    
    fileprivate struct CreatePostResponseMessage : Codable {
        let message: String?
        let id: String?
        let status: Int?
    }
    
    fileprivate struct GetAllPostsRequestMessage: Codable {
        
    }
    
    fileprivate struct GetPostsResponse: Codable {
        var response: [PostData]?
        var status: Int?
        var message:String?
    }
    
    // MARK - API METHODS
    
    fileprivate func submitCreatePostRequest(content: String?, imageIds: String?, closure: @escaping(Result<PostData, CreatePostError>) -> Void) {
        let submitPostRequest = APIRequest(endpoint: "create_post", httpMethod: "POST")

        let message = CreatePostMessage(content: content, images: imageIds)
        let response = CreatePostResponseMessage(message: nil, id: nil, status: nil)
        
        submitPostRequest.save(message: message, response: response, completion: { result in
            switch result {
            case .success(let message):
                // Create PostData Model here
                let newPost = PostData(id: message.id!, username: Session.shared.username, timestamp: Date().description, content: content!, images: imageIds)
                
                closure(.success(newPost))
            case .failure(let error):
                if error == .responseProblem {
                    closure(.failure(.connectionProblem))
                }
                
            }
        })
    }
    
    static func getAllPosts(completion: @escaping(Result<[Post]?, APIError>) -> Void) -> Void {
        // Make API request to backend to signup.
        let getAllPostsRequest = APIRequest(endpoint: "get_all_posts", httpMethod: "GET")
        
        let message = GetAllPostsRequestMessage()
        let response = GetPostsResponse()
        getAllPostsRequest.save(message: message,response: response, completion: { result in
            switch result {
            case .success(let message):
                print("POST request response: \"\(message.status)\"")
                var postmodels = [Post]()
                
                // Decode posts json into postModels for app use
                if let posts = message.response {
                    for post in posts {
                        var imageRefs: [String]? = nil
                        if let imageIds = post.images {
                            imageRefs = [imageIds]
                        }
                        
                        let dateString:String = String(post.timestamp.dropFirst().dropLast())

                        let postModel = Post(id: post.id, username: post.username, timestamp: DateStringFormatter.dateFormatFromString(dateString)!, content: post.content, imageRefs: imageRefs)
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

