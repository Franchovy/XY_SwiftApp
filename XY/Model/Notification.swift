//
//  Notification.swift
//  XY
//
//  Created by Maxime Franchot on 19/01/2021.
//

import Foundation
import Firebase

enum NotificationType {
    case swipeRight
    case swipeLeft
    case levelUp
    
    var text: String {
        switch self {
        case .swipeRight: return "Swiped Right on your Post"
        case .swipeLeft: return "Swipe Left on your Post"
        case .levelUp: return "Post Leveled Up"
        }
    }
}

struct Notification {
    let type: NotificationType
    let objectId: String
    let senderId: String
    let timestamp: Date
}

extension Notification {
    init(_ data: [String: Any]) {
        type = {
            switch data[FirebaseKeys.NotificationKeys.notifications.type] as! String {
            case "swipeRight": return .swipeRight
            case "swipeLeft": return .swipeLeft
            case "levelUp": return .levelUp
            default:
                fatalError("Notification type not found!")
            }
        }()
        senderId = data[FirebaseKeys.NotificationKeys.notifications.senderId] as! String
        objectId = data[FirebaseKeys.NotificationKeys.notifications.objectId] as! String
        timestamp = (data[FirebaseKeys.NotificationKeys.notifications.timestamp] as! Firebase.Timestamp).dateValue()
    }
}
