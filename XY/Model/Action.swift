//
//  XYAction.swift
//  XY_APP
//
//  Created by Maxime Franchot on 12/01/2021.
//

import Firebase

enum ActionType {
    case swipeRight
    case levelUp
}

struct Action {
    static func getSwipeRightAction(postId: String, xp: Int) -> [String: Any] {
        let userId = Auth.auth().currentUser!.uid
        let type = ActionType.swipeRight
        return [ FirebaseKeys.ActionKeys.user : userId,
                 FirebaseKeys.ActionKeys.item : postId,
                 FirebaseKeys.ActionKeys.xp : xp,
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
