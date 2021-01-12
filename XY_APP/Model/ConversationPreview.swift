//
//  ConversationPreview.swift
//  XY_APP
//
//  Created by Simone on 03/01/2021.
//

import Foundation
import UIKit

struct ConversationPreview {
    var timestamp: Date
    var conversationId: String
    var senderId: String
    var senderImage: UIImage
    var senderName: String
    var messagePreview: String
    var mostRecentMessageTimestamp: Date
}
