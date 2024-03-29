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
        
        static let users = "Users"
        static let posts = "Posts"
        static let profile = "Profiles"
        static let actions = "Actions"
        static let notifications = "Notifications"
        static let moments = "Moments"
        static let conversations = "Conversations"
        static let virals = "Viral"
        static let relationships = "Relationships"
        static let challenges = "Challenges"
        
        static let comments = "comments"
        
        // deprecate
        static let messages = "messages"
        static let senderField = "senderField"
        static let bodyField = "bodyField"
        static let dateField = "dateField"
    }
    
    struct LevelKeys {
        static let postLevels = "postLevels"
        static let userLevels = "userLevels"
        static let viralLevels = "viralLevels"
        static let viralLives = "viralLives"
    }
    
    struct ViralKeys {
        static let caption = "caption"
        static let level = "level"
        static let xp = "xp"
        static let profileId = "profileId"
        static let videoRef = "videoRef"
        static let livesLeft = "livesLeft"
    }
    
    struct ActionKeys {
        static let timestamp = "timestamp"
        static let type = "type"
        static let contentType = "contentType"
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
            static let timestamp = "timestamp"
            static let objectType = "objectType"
        }
    }
    
    struct UserKeys {
        static let xyname = "xyname"
        static let timestamp = "timestamp"
        static let xp = "xp"
        static let level = "level"
        static let profile = "profile"
        static let hidden = "hidden"
        static let fcmToken = "fcmToken"
    }
    
    struct ProfileKeys {
        static let nickname = "nickname"
        static let caption = "caption"
        static let followers = "followers"
        static let following = "following"
        static let swipeRights = "swipeRights"
        static let profileImage = "profileImage"
        static let coverImage = "coverImage"
        static let level = "level"
        static let website = "website"
        static let xp = "xp"
        static let numFriends = "numFriends"
        static let numChallenges = "numChallenges"
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
        
        struct Comments {
            static let author = "author"
            static let comment = "comment"
            static let timestamp = "timestamp"
            static let level = "level"
            static let xp = "xp"
        }
    }
    
    struct RelationshipKeys {
        static let users = "users"
        
        static let type = "type"
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
    
    struct ChallengeKeys {
        static let title = "title"
        static let creatorID = "creatorID"
        static let description = "description"
        static let gradient = "gradient"
        static let xp = "xp"
        static let level = "level"
        static let category = "category"
        
        struct CollectionPath {
            static let videos = "videos"
        }
        
        struct VideoKeys {
            static let challengeID = "challengeID"
            static let videoRef = "videoRef"
            static let creatorID = "creatorID"
            static let xp = "xp"
            static let level = "level"
            static let caption = "caption"
            static let timestamp = "timestamp"
        }
    }
    
    struct MomentsKeys {
        static let author = "author"
        static let timestamp = "timestamp"
        static let videoRef = "videoRef"
    }
}
