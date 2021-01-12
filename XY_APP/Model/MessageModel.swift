//
//  Messages.swift
//  XY_APP
//
//  Created by Simone on 04/01/2021.
//

import Foundation
import UIKit
import Firebase

struct MessageModel {
    var senderId: String
    var message: String
    var timeLabel: Date
}

extension MessageModel {
    init(_ data: [String: Any]) {
        senderId = data[FirebaseKeys.ConversationKeys.MessagesKeys.sender] as! String
        message = data[FirebaseKeys.ConversationKeys.MessagesKeys.message] as! String
        timeLabel = (data[FirebaseKeys.ConversationKeys.MessagesKeys.timestamp] as! Firebase.Timestamp).dateValue()
    }
}
