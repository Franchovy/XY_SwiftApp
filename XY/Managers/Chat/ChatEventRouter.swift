//
//  ChatEventRouter.swift
//  XY
//
//  Created by Maxime Franchot on 15/02/2021.
//

import Foundation

final class ChatEventRouter {
    static func route(event: ChatEvent) {
        switch event {
        case .sending(message: let message, contact: let contact, previousMessages: let previousMessages):
            break
        case .sent(message: let message, contact: let contact):
            break
        case .failedSending(message: let message, contact: let contact, reason: let reason):
            break
        case .received(message: let message, contact: let contact):
            break
        case .userReads(messagesSentBy: let messagesSentBy):
            break
        case .userRead(othersMessages: let othersMessages, sentBy: let sentBy):
            break
        case .otherRead(yourMessage: let yourMessage, reader: let reader):
            break
        }
    }
}
