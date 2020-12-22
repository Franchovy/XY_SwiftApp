//
//  Post.swift
//  XY_APP
//
//  Created by Maxime Franchot on 28/11/2020.
//

import Foundation
import UIKit

class PostManager {
    static var shared = PostManager()
    
    var posts: [String: PostData] = [:]
    
    func addPosts(_ posts: [PostData]) {
        for post in posts {
            self.posts[post.id] = post
        }
    }
    
    func updateXP(postId: String, xpLevel: XPLevel) {
        guard var postToUpdate = posts[postId] else { return }
        
        postToUpdate.xpLevel = xpLevel
        
        posts[postId] = postToUpdate
    }
    
    func getPostWithId(id: String) -> PostData? {
        // If cached, get it directly.
        return posts[id]
    }
}

struct PostData {
    var id: String
    var username: String
    var timestamp: Date
    var content: String
    var images: [String]?
    
    var xpLevel : XPLevel
    var feedback: Feedback?
    
    // Create new post:
    init(id: String, username: String, timestamp: Date, content: String, images: [String]?) {
        self.id = id
        self.username = username
        self.timestamp = timestamp
        self.content = content
        self.images = images
        self.xpLevel = XPLevel(type: .post)
        feedback = Feedback()
    }
}

extension PostData : Decodable {
    enum CodingKeys: CodingKey {
      case id, username, timestamp, content, images, xpLevel
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.xpLevel) {
            id = try container.decode(String.self, forKey: .id)
            username = try container.decode(String.self, forKey: .username)
            timestamp = try container.decode(Date.self, forKey: .timestamp)
            content = try container.decode(String.self, forKey: .content)
            if container.contains(.images) {
                images = try container.decode([String].self, forKey: .images)
            }
            xpLevel = try container.decode(XPLevel.self, forKey: .xpLevel)
            feedback = Feedback()
        } else {
            id = try container.decode(String.self, forKey: .id)
            username = try container.decode(String.self, forKey: .username)
            timestamp = try container.decode(Date.self, forKey: .timestamp)
            content = try container.decode(String.self, forKey: .content)
            if container.contains(.images) {
                images = try container.decode([String].self, forKey: .images)
            }
            xpLevel = XPLevel(type: .post)
            feedback = Feedback()
        }
    }
}
