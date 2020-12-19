//
//  Post.swift
//  XY_APP
//
//  Created by Maxime Franchot on 28/11/2020.
//

import Foundation
import UIKit

struct PostData: Codable {
    var id: String
    var username: String
    var timestamp: String
    var content: String
    var images: String?
}


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
    
    // MARK - PUBLIC METHODS
    
    func loadPhotos(completion: @escaping([UIImage]) -> Void) {
        
    }
    
    
    func submitPost(, completion: @escaping(PostData?) -> Void) {
        
        
                        
                        // If all uploads are complete send Submit Post request
                        if self.imageRefs?.count == images.count {
                            PostsAPI.shared.submitCreatePostRequest(content: self.content, imageIds: self.imageRefs?.first, closure: { result in
                                switch result{
                                case .success(let postData):
                                    completion(postData)
                                case .failure(let error):
                                    print("Failed to get post: \(error).")
                                    completion(nil)
                                }
                            })
                        }
                        
                    case .failure(let error):
                        print("Error submitting image for post: \(error)")
                    }
                })
            }
        } else {
            // No images to upload, submit directly
            PostsAPI.shared.submitCreatePostRequest(content: self.content, imageIds: self.imageRefs?.first, closure: { result in
                switch result{
                case .success(let postData):
                    completion(postData)
                case .failure(let error):
                    print("Failed to get post: \(error).")
                    completion(nil)
                }
            })
        }
    }
    
    // MARK - API STRUCTS
    
    
    // MARK - API METHODS
    
    
}

