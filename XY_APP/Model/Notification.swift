//
//  Notification.swift
//  XY
//
//  Created by Maxime Franchot on 19/01/2021.
//

import Foundation

enum NotificationType {
    case swipeRight
    case swipeLeft
    case levelUp
    
    var title: String {
        switch self {
        case .swipeRight: return "Swipe Right"
        case .swipeLeft: return "Swipe Left"
        case .levelUp: return "Level Up"
        }
    }
}

struct Notification {
    let type: NotificationType
    let objectId: String
    let senderId: String
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
    }
}
