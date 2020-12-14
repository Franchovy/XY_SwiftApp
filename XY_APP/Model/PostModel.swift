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
    
    struct CreatePostMessage: Codable {
        var content: String?
        var images: String?
    }
    
    struct CreatePostResponseMessage : Codable {
        let message: String?
        let id: String?
        let status: Int?
    }
    
    //
    func submitPost(images: [UIImage]?, completion: @escaping(Result<CreatePostResponseMessage, APIError>) -> Void) {
        let submitPostRequest = APIRequest(endpoint: "create_post", httpMethod: "POST")
        
        // If images are not null then upload them
        if let images = images, images.count > 0 {
            for image in images {
                ImageManager.uploadImage(image: image, completionHandler: { imageResponse in
                    if imageResponse.id != "" {
                        self.imageRefs?.append(imageResponse.id)
                        
                        // If all uploads are complete:
                        if self.imageRefs?.count == images.count {
                            let message = CreatePostMessage(content: self.content, images: self.imageRefs?.first)
                            let response = CreatePostResponseMessage(message: nil, id: nil, status: nil)
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
                    } else {
                        fatalError("Error connecting to backend")
                    }
                })
            }
        } else {
            // Text only upload
            let message = CreatePostMessage(content: self.content, images: imageRefs?.first)
            let response = CreatePostResponseMessage(message: nil, id: nil, status: nil)
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
    }
    
    struct GetAllPostsRequestMessage: Codable {
        
    }
    
    final class GetPostsResponse: Codable {
        var response: [PostData]?
        var status: Int?
        var message:String?
    }
    
    struct PostData: Codable {
        var username: String
        var content: String
        var images: String?
        
        enum CodingKeys: String, CodingKey {
           case username, content, images
        }
    }
    
    // Function to fetch from API to get all recent posts.
    static func getAllPosts(completion: @escaping(Result<[PostModel]?, APIError>) -> Void) -> Void {
        // Make API request to backend to signup.
        let getAllPostsRequest = APIRequest(endpoint: "get_all_posts", httpMethod: "GET")
        
        let message = GetAllPostsRequestMessage()
        let response = GetPostsResponse()
        getAllPostsRequest.save(message: message,response: response, completion: { result in
            switch result {
            case .success(let message):
                print("POST request response: \"\(message.status)\"")
                var postmodels = [PostModel]()
                
                // Decode posts json into postModels for app use
                if let posts = message.response {
                    for post in posts {
                        var imageRefs: [String]? = nil
                        if let images = post.images {
                            imageRefs = [images]
                        }
                        
                        let postModel = PostModel(username: post.username, content: post.content, imageRefs: imageRefs)
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
                ImageManager.downloadImage(imageID: imgRef, completion: { image in
                    if let img = image {
                        let resizingFactor = 200 / img.size.height
                        let newImage = UIImage(cgImage: img.cgImage!, scale: img.scale / resizingFactor, orientation: .up)
                        
                        self.images!.append(newImage)
                    }
                    // Run completion handler once images are downloaded
                    if self.images!.count == imageRefs.count {
                        completion(self.images!)
                    }
                })
            }
        }
        
    }
}

