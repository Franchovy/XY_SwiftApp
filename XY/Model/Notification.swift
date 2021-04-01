//
//  Notification.swift
//  XY
//
//  Created by Maxime Franchot on 19/01/2021.
//

import Foundation
import Firebase

enum _NotificationType: String {
    case swipeRight
    case swipeLeft
    case levelUp
    case lifeOut
    
    var text: String {
        switch self {
        case .swipeRight: return "Swiped Right on your _"
        case .swipeLeft: return "Swipe Left on your _"
        case .levelUp: return "_ Leveled Up"
        case .lifeOut: return "Your _ ran out of life"
        }
    }
}

enum ObjectType: String {
    case post
    case moment
    case viral
    case user
    
    var text: String {
        switch self {
        case .post: return "Post"
        case .moment: return "Moment"
        case .viral: return "Viral"
        case .user: return "User"
        }
    }
}

struct Notification {
    let notificationId: String
    let type: _NotificationType
    let objectId: String
    let objectType: ObjectType
    let senderId: String?
    let timestamp: Date
}

extension Notification {
    init(_ data: [String: Any], id: String) {
        type = _NotificationType(rawValue: data[FirebaseKeys.NotificationKeys.notifications.type] as! String)!
        objectType = ObjectType(rawValue: data[FirebaseKeys.NotificationKeys.notifications.objectType] as! String)!
        
        notificationId = id
        senderId = data[FirebaseKeys.NotificationKeys.notifications.senderId] as? String
        objectId = data[FirebaseKeys.NotificationKeys.notifications.objectId] as! String
        
        timestamp = (data[FirebaseKeys.NotificationKeys.notifications.timestamp] as! Firebase.Timestamp).dateValue()
    }
}
