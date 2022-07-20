//
//  XYAction.swift
//  XY_APP
//
//  Created by Maxime Franchot on 12/01/2021.
//

import Firebase

enum ActionType: String {
    case swipeRight
    case swipeLeft
    case levelUp
    case delete
}

enum ContentType: String {
    case challenge
}

struct Action {
    
    let senderId: String
    let objectId: String
    let xp: Int?
    let level: Int?
    let timestamp: Date
    let type: ActionType
    
    init(fromData data: [String: Any]) {
        self.senderId = data[FirebaseKeys.ActionKeys.user] as! String
        self.objectId = data[FirebaseKeys.ActionKeys.item] as! String
        self.xp = data[FirebaseKeys.ActionKeys.xp] as? Int
        self.level = data[FirebaseKeys.ActionKeys.level] as? Int
        self.timestamp = (data[FirebaseKeys.ActionKeys.timestamp] as! Firebase.Timestamp).dateValue()
        self.type = ActionType(rawValue: data[FirebaseKeys.ActionKeys.type] as! String)!
    }
    
    static func getSwipeRightAction(id: String, contentType: ContentType, xp: Int) -> [String: Any] {
        let userId = AuthManager.shared.userId
        let type = ActionType.swipeRight
        return [ FirebaseKeys.ActionKeys.user : userId,
                 FirebaseKeys.ActionKeys.item : id,
                 FirebaseKeys.ActionKeys.xp : xp,
                 FirebaseKeys.ActionKeys.contentType: contentType.rawValue,
                 FirebaseKeys.ActionKeys.timestamp : FieldValue.serverTimestamp(),
                 FirebaseKeys.ActionKeys.type : String(describing: type)
        ]
    }
    
    static func getSwipeLeftAction(id: String, contentType: ContentType, xp: Int) -> [String: Any] {
        let userId = AuthManager.shared.userId
        let type = ActionType.swipeLeft
        return [ FirebaseKeys.ActionKeys.user : userId,
                 FirebaseKeys.ActionKeys.item : id,
                 FirebaseKeys.ActionKeys.xp : xp,
                 FirebaseKeys.ActionKeys.contentType: contentType.rawValue,
                 FirebaseKeys.ActionKeys.timestamp : FieldValue.serverTimestamp(),
                 FirebaseKeys.ActionKeys.type : String(describing: type)
        ]
    }
    
    static func getLevelUpAction(docId: String, level: Int) -> [String: Any] {
        let type = ActionType.levelUp
        return [
            FirebaseKeys.ActionKeys.type : String(describing: type),
            FirebaseKeys.ActionKeys.timestamp : FieldValue.serverTimestamp(),
            FirebaseKeys.ActionKeys.item : docId,
            FirebaseKeys.ActionKeys.level : level
        ]
    }
}
