//
//  ChatViewModelBuilder.swift
//  XY
//
//  Created by Maxime Franchot on 15/02/2021.
//

import Foundation

final class ChatViewModelBuilder {
    static func build(for chatModels: [Message], conversationViewModel: ConversationViewModel) -> [MessageViewModel] {
        
        return chatModels.map { (messageModel) in
            return MessageViewModel(
                text: messageModel.messageText,
                timestamp: messageModel.timestamp,
                nickname: conversationViewModel.name,
                senderIsSelf: AuthManager.shared.userId == messageModel.senderId
            )
        }
    }
}
