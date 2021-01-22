//
//  FirebaseKeys.swift
//  XY_APP
//
//  Created by Maxime Franchot on 04/01/2021.
//

import Firebase

struct FirebaseKeys {
    
    struct CollectionPath {
        ///Defining the collection path for each of these
        
        static let users = "users"
        static let posts = "Posts"
        static let profile = "Profiles"
        static let actions = "Actions"
        static let notifications = "Notifications"
        
        static let conversations = "Conversations"
        static let messages = "messages"
        static let senderField = "senderField"
        static let bodyField = "bodyField"
        static let dateField = "dateField"
    }
    
    struct ActionKeys {
        static let timestamp = "timestamp"
        static let type = "type"
        
        static let item = "item"
        static let user = "user"
        static let xp = "xp"
        static let level = "lvl"
    }
    
    struct NotificationKeys {
        static let user = "user"
        static let notificationsCollection = "notifications"
        struct notifications {
            static let objectId = "objectId"
            static let senderId = "senderId"
            static let type = "type"
        }
    }
    
    struct UserKeys {
        static let xyname = "xyname"
        static let timestamp = "timestamp"
        static let xp = "xp"
        static let level = "level"
        static let profile = "profile"
    }
    
    struct ProfileKeys {
        static let nickname = "nickname"
        static let caption = "caption"
        static let followers = "followers"
        static let following = "following"
        static let profileImage = "profileImage"
        static let coverImage = "coverImage"
        static let level = "level"
        static let website = "website"
        static let xp = "xp"
    }
    
    struct PostKeys {
        static let author = "author"
        static let postData = "postData"
        static let timestamp = "timestamp"
        static let xp = "xp"
        static let level = "level"
        static let swipeRight = "swipeRight"
        static let swipeLeft = "swipeLeft"
        static let lives = "lives"

        struct PostData {
            static let caption = "caption"
            static let imageRef = "imageRef"
        }
    }
    
    struct ConversationKeys {
        static let xp = "xp"
        static let level = "level"
        static let messages = "messages"
        static let members = "members"
        static let timestamp = "timestamp"
        static let mostRecentMessageTimestamp = "mostRecent"
        
        struct MessagesKeys {
            static let timestamp = "timestamp"
            static let sender = "sender"
            static let message = "message"
        }
    }
}