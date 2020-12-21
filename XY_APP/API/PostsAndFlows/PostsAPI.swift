//
//  PostsAPI.swift
//  XY_APP
//
//  Created by Maxime Franchot on 19/12/2020.
//

import Foundation

//extension PostData: Decodable {
//
//  private enum Key: String, CodingKey {
//    case id = "id"
//    case username = "username"
//    case timestamp = "timestamp"
//    case images = "images"
//    case content = "content"
//  }
//
//  init(from decoder: Decoder) throws {
//    let container = try decoder.container(keyedBy: Key.self)
//    self.content = try container.decode(String.self, forKey: .content)
//    self.images = try container.decode([String].self, forKey: .images)
//    self.id = try container.decode(String.self, forKey: .id)
//    self.timestamp = try container.decode(Date.self, forKey: .timestamp)
//    self.username = try container.decode(String.self, forKey: .username)
//  }
//}

class PostsAPI {
    
    static var shared = PostsAPI()
    
    enum CreatePostError:Error {
        case otherProblem
        case connectionProblem
    }
    
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
    
    fileprivate struct GetPostsResponse: Decodable {
        
        var response: [PostData]?
        var status: Int?
        var message:String?
    }
    
    
    func submitCreatePostRequest(content: String?, imageIds: [String]?, closure: @escaping(Result<PostData, CreatePostError>) -> Void) {
        let submitPostRequest = APIRequest(endpoint: "create_post", httpMethod: "POST")

        let message = CreatePostMessage(content: content, images: imageIds?.first)
        let response = CreatePostResponseMessage(message: nil, id: nil, status: nil)
        
        submitPostRequest.save(message: message, response: response, completion: { result in
            switch result {
            case .success(let message):
                // Create PostData Model here
                let newPost = PostData(id: message.id!, username: Session.shared.username, timestamp: Date(), content: content!, images: imageIds)
                
                closure(.success(newPost))
            case .failure(let error):
                if error == .responseProblem {
                    closure(.failure(.connectionProblem))
                }
                
            }
        })
    }

    func getAllPosts(completion: @escaping(Result<[PostData]?, APIError>) -> Void) {
        // Make API request to backend to signup.
        let getAllPostsRequest = APIRequest(endpoint: "get_all_posts", httpMethod: "GET")
        
        let message = GetAllPostsRequestMessage()
        let response = GetPostsResponse()
        getAllPostsRequest.save(message: message,response: response, completion: { result in
            switch result {
            case .success(let message):
                var postmodels = [PostData]()
                // Decode posts json into postModels for app use
                if let posts = message.response {
                    for post in posts {
                        var imageRefs: [String]? = nil
                        
                        let dateString:String = post.timestamp.description
                        print("Datestring: \(dateString)")

                        let postModel = PostData(id: post.id, username: post.username, timestamp: post.timestamp, content: post.content, images: post.images)
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
