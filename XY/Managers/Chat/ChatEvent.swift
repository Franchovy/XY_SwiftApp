//
//  ChatEvent.swift
//  XY
//
//  Created by Maxime Franchot on 15/02/2021.
//

import Foundation

enum ChatEvent {
    case sending(message: Message, contact: String, previousMessages: [Message])
    case sent(message: Message, contact: String)
    case failedSending(message: Message, contact: String, reason: String)
    case received(message: Message, contact: String)
    case userReads(messagesSentBy: String)
    case userRead(othersMessages: [Message], sentBy: String)
    case otherRead(yourMessage: Message, reader: String)
}
