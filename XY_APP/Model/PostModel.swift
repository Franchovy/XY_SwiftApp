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
    
    func updateFeedback(postId: String, viewTime: Int, swipeRights: Int, swipeLefts: Int) -> Feedback {
        guard var postToUpdate = posts[postId] else { return Feedback() }
        
        if postToUpdate.feedback != nil {
            postToUpdate.feedback?.swipeRight += swipeRights
            postToUpdate.feedback?.swipeLeft += swipeLefts
            postToUpdate.feedback?.viewTime += Float(viewTime)
        } else {
            postToUpdate.feedback = Feedback(swipeRight: swipeRights, swipeLeft: swipeLefts, viewTime: Float(viewTime))
        }
        
        posts[postId] = postToUpdate
        return postToUpdate.feedback!
    }
    
    func getXP(postId: String) -> XPLevel {
        guard var post = posts[postId] else { return XPLevel(type: .post) }
        // Get XP using XP and from post feedback
        var xpLevel = post.xpLevel
        
        xpLevel.addXP(xp: post.feedback!.viewTime + Float(post.feedback!.swipeRight * 15))
        
        return xpLevel
    }
    
    // Only call this after receiving API response!
    func addXPUpdateData(updatedXPDataArray: [FeedbackAPI.PostXPUpdateData]) {
        for updateXPData in updatedXPDataArray {
            guard var postToUpdate = posts[updateXPData.id] else { continue }
            
            // XP should be the same before and after XP Update Data operation
            let val = PostManager.shared.getXP(postId: postToUpdate.id)
            
            postToUpdate.xpLevel.addXP(xp: Float(updateXPData.xp))
            postToUpdate.feedback = Feedback()
            posts[updateXPData.id] = postToUpdate
            
            let val2 = PostManager.shared.getXP(postId: postToUpdate.id)
            //if val.level != val2.level && val.xp != val2.xp { fatalError() }
        }
    }
    
//    // Takes a post, and a new xpLevel to apply, setting the new xp level for this post in the storage.
//    func updateXP(postId: String, xpLevel: XPLevel) {
//        guard var postToUpdate = posts[postId] else { return }
//
//        postToUpdate.xpLevel = xpLevel
//
//        // Check to see if level has been passed
//        if Levels.shared.getNextLevel(xpLevel: xpLevel) < xpLevel.xp {
//            postToUpdate.xpLevel.levelUp()
//        }
//
//        posts[postId] = postToUpdate
//    }
//
//    func addXP(postId: String, xp: Float) -> PostData? {
//        // Updates the model to have more xp
//        guard let post = posts[postId] else {return nil}
//        var newXpLevel = post.xpLevel
//        newXpLevel.addXP(xp: xp)
//        // Update xp in storage
//        updateXP(postId: postId, xpLevel: newXpLevel)
//        // Return updated
//        return posts[postId]
//    }
    
    func getPostWithId(id: String) -> PostData? {
        // If cached, get it directly.
        return posts[id]
    }
}

struct PostData {
    var id: String
    var username: String
    var profileImage: String?
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

struct PostViewModel {
    var xyname: String
    var profileImage: UIImage?
    var timestamp: Date
    var content: String
    var images: [UIImage]?
    
    var xpLevel : XPLevel
    var feedback: Feedback?
    
    // Create new post:
    init(id: String, xyname: String, timestamp: Date, content: String, images: [UIImage]?) {
        self.xyname = xyname
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
