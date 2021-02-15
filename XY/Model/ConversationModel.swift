//
//  ConversationPreview.swift
//  XY_APP
//
//  Created by Simone on 03/01/2021.
//

import Foundation
import UIKit
import Firebase

struct ConversationPreview {
    var timestamp: Date?
    var conversationId: String
    var senderId: String?
    var senderImage: UIImage?
    var senderName: String?
    var messagePreview: String?
    var latestMessageTimestamp: Date?
}

struct ConversationModel {
    var id: String
    var timestamp: Date
    var members: [String]
    var level: Int
    var xp: Int
    var messagesRef: Firebase.CollectionReference?
}

extension ConversationModel {
    init(_ data: [String: Any], id: String) {
        self.id = id
        timestamp = (data[FirebaseKeys.ConversationKeys.timestamp] as! Firebase.Timestamp).dateValue()
        members = (data[FirebaseKeys.ConversationKeys.members] as! [String:Bool]).map({ $0.key })
        level = data[FirebaseKeys.ConversationKeys.level] as! Int
        xp = data[FirebaseKeys.ConversationKeys.xp] as! Int
    }
    
    static func newConversationData(members: [String]) -> [String: Any] {
        return [
            FirebaseKeys.ConversationKeys.level : 0,
            FirebaseKeys.ConversationKeys.xp : 0,
            FirebaseKeys.ConversationKeys.members : members,
            FirebaseKeys.ConversationKeys.timestamp : Firebase.FieldValue.serverTimestamp(),
        ]
    }
}
