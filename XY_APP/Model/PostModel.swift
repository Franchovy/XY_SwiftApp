//
//  Post.swift
//  XY_APP
//
//  Created by Maxime Franchot on 28/11/2020.
//

import Foundation
import UIKit

struct PostData {
    var id: String
    var username: String
    var timestamp: Date
    var content: String
    var images: [String]?
    
    var xpLevel : XPLevel
    var feedback: FeedbackData?
    
    // Create new post:
    init(id: String, username: String, timestamp: Date, content: String, images: [String]?) {
        self.id = id
        self.username = username
        self.timestamp = timestamp
        self.content = content
        self.images = images
        self.xpLevel = XPLevel(type: .post)
        feedback = FeedbackData()
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
            feedback = FeedbackData()
        } else {
            id = try container.decode(String.self, forKey: .id)
            username = try container.decode(String.self, forKey: .username)
            timestamp = try container.decode(Date.self, forKey: .timestamp)
            content = try container.decode(String.self, forKey: .content)
            if container.contains(.images) {
                images = try container.decode([String].self, forKey: .images)
            }
            xpLevel = XPLevel(type: .post)
            feedback = FeedbackData()
        }
    }
}
