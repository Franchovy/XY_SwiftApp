//
//  ChatEventHandler.swift
//  XY
//
//  Created by Maxime Franchot on 15/02/2021.
//

import Foundation

protocol ChatsListening: class {
    func updated(chats: [MessageViewModel], conversationId: String)
}

final class ChatEventHandler {
    private static var chatListeners = [String: [ChatsListening?]]()
    
    class func add(forId id: String, listener: ChatsListening) {
        weak var weakListener = listener
        if chatListeners.keys.contains(id) {
            chatListeners[id]?.append(weakListener)
        } else {
            chatListeners[id] = [weakListener]
        }
    }
    
    class func remove(listener: ChatsListening) {
        
        for chatListener in chatListeners {
            if chatListener.value.contains(where: { $0 === listener }) {
                if chatListener.value.count == 1 {
                    chatListeners.removeValue(forKey: chatListener.key)
                } else {
                    chatListeners[chatListener.key]?.removeAll(where: { $0 === listener})
                }
            }
        }
    }
    
    class func remove(id: String) {
        chatListeners = chatListeners.filter { $0.key != id }
    }
    
    class func loaded(chats: [Message]) {
//        let chatList = ChatViewModelBuilder.build(for: chats, conversationViewModel: <#T##ConversationViewModel#>)
//        chatListeners.forEach { $0?.updated(chats: chatList) }
    }
    
}
