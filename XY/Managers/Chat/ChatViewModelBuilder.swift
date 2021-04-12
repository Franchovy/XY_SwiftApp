//
//  ChatViewModelBuilder.swift
//  XY
//
//  Created by Maxime Franchot on 15/02/2021.
//

import Foundation

final class ChatViewModelBuilder {
    static func build(for chatModels: [Message], conversationViewModel: ConversationViewModel) -> [MessageViewModel] {
        guard let userId = AuthManager.shared.userId, let ownNickname = _ProfileManager.shared.ownProfile?.nickname else {
            fatalError()
        }
        
        return chatModels.map { (messageModel) in
            let senderIsSelf = userId == messageModel.senderId
            
            return MessageViewModel(
                text: messageModel.messageText,
                timestamp: messageModel.timestamp,
                nickname: senderIsSelf ? ownNickname : conversationViewModel.name,
                senderIsSelf: senderIsSelf
            )
        }
    }
}
